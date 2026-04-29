# `edit` command opens files in your editor
ENV['EDITOR'] = 'code'

IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:INSPECT_MODE] = :pp
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:COMPLETOR] = :type

autoload :CSV, 'csv'
autoload :Date, 'date'
autoload :JSON, 'json'
autoload :Time, 'time'
autoload :YAML, 'yaml'

Reline::Face.config(:completion_dialog) do |conf|
  # Slightly lighter black than :black ('#222121')
  default_background_color = '#3C3B3B'

  conf.define :default, foreground: :white, background: default_background_color
  conf.define :enhanced, foreground: '#FFFFFF', background: '#005bbb'
  conf.define :scrollbar, foreground: :gray, background: default_background_color
end

module GlobalGemLoader
  module_function

  # Load a globally installed gem even under Bundler.
  def require!(gem_name, require_path = gem_name)
    # Try the normal RubyGems lookup first.
    spec = Gem::Specification.find_all_by_name(gem_name).max_by(&:version)
    gem_path =
      if spec
        spec.full_gem_path
      else
        # Fall back to the gemspec because Bundler hides gems outside Gemfile.
        gemspec = Gem::Specification.dirs
          .flat_map { |dir| Dir.glob(File.join(dir, "#{gem_name}-*.gemspec")) }
          .max

        raise LoadError, "#{gem_name} gem is not installed" unless gemspec

        installed_gem_name = File.basename(gemspec, ".gemspec")
        File.expand_path("../gems/#{installed_gem_name}", File.dirname(gemspec))
      end

    # Add the gem's lib dir so its internal requires work.
    lib_path = File.join(gem_path, "lib")
    $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
    require require_path
  end
end

# === install-irbrc-gems ===

require "irb/command"

class InstallIrbrcGems < IRB::Command::Base
  category "irbrc"
  description "Install gems required by .irbrc"

  GEMS = %w[anbt-sql-formatter pp_sql].freeze

  def execute(_arg)
    require 'rubygems/dependency_installer'

    GEMS.each do |name|
      if Gem::Specification.dirs.any? { |dir| Dir.glob(File.join(dir, "#{name}-*.gemspec")).any? }
        puts "#{name}: already installed"
      else
        print "#{name}: installing..."
        specs = Gem::DefaultUserInteraction.use_ui(Gem::SilentUI.new) do
          Gem::DependencyInstaller.new.install(name)
        end
        puts " done (#{specs.first.version})"
      end
    end
  end
end

IRB::Command.register(:install_irbrc_gems, InstallIrbrcGems)

# === irb-history-picker ===

require "open3"
require "io/console"

# Add a Ctrl-R history picker to IRB using an external picker such as peco or fzf.
# Keep the picker integration isolated here so the selected entry can be restored
# through Reline's history handling instead of mutating the line buffer directly.
module IRBHistoryPicker
  DEFAULT_CONFIG = {
    picker: :peco,
    picker_options: {
      peco: [],
      fzf: []
    }
  }.freeze

  class << self
    def activate!(context)
      return unless defined?(IRB::RelineInputMethod)
      return unless context.io.is_a?(IRB::RelineInputMethod)

      unless Reline::LineEditor < HistoryPickerCommand
        Reline::LineEditor.prepend(HistoryPickerCommand)
      end

      Reline.core.config.bind_key('"\\C-r"', "history-picker")
    end

    def config
      @config ||= {
        picker: DEFAULT_CONFIG.fetch(:picker),
        picker_options: DEFAULT_CONFIG.fetch(:picker_options).transform_values(&:dup)
      }
    end

    def configure
      yield(config)
    end

    def pick_history_index
      entries = build_history_entries
      return if entries.empty?

      selected = pick(entries.keys)
      return if selected.nil? || selected.empty?

      entries[selected]
    end

    private

    def build_history_entries
      seen = {}
      history = Reline::HISTORY.to_a

      (history.length - 1).downto(0).each_with_object({}) do |index, entries|
        cmd = history[index]
        next if cmd.strip.empty?
        next if seen.key?(cmd)

        seen[cmd] = true

        display = cmd
          .gsub("\n", " ⏎ ")
          .gsub("\t", " ⇥ ")

        entries[display] = index
      end
    end

    def pick(lines)
      # Temporarily restore normal terminal input mode for the external picker.
      selected, status = STDIN.cooked do
        Open3.capture2(*picker_command, stdin_data: lines.join("\n") + "\n")
      end
      return unless status.success?

      selected.delete_suffix("\n")
    rescue Errno::ENOENT
      warn "irb-history-picker: `#{picker_command.first}` was not found"
      nil
    end

    def picker_command
      picker = config.fetch(:picker)
      options = config.fetch(:picker_options).fetch(picker, [])

      case picker
      when :peco
        ["peco", *options]
      when :fzf
        ["fzf", *options]
      else
        raise ArgumentError, "unsupported picker: #{picker.inspect}"
      end
    end
  end

  module HistoryPickerCommand
    private

    def history_picker(_key)
      history_index = IRBHistoryPicker.pick_history_index
      return unless history_index

      # Restore the original history entry instead of the picker display string.
      move_history(history_index, line: :end, cursor: :end)
    end
  end
end

# === rails-sql-formatter ===

# Enable pp_sql log formatting only in Rails console.
module RailsSqlFormatter
  class << self
    def activate!
      return unless defined?(Rails::Console)

      GlobalGemLoader.require!("anbt-sql-formatter", "anbt-sql-formatter/formatter")
      GlobalGemLoader.require!("pp_sql")

      # Keep the original to_sql behavior.
      PpSql.rewrite_to_sql_method = false
      # Format SQL only in Rails logs.
      PpSql.add_rails_logger_formatting = true

      # Apply the patch whether Active Record is already loaded or not.
      ActiveSupport.on_load(:active_record) do
        unless ActiveRecord::Relation.ancestors.include?(PpSql::ToSqlBeautify)
          ActiveRecord::Relation.prepend(PpSql::ToSqlBeautify)
        end

        unless ActiveRecord::LogSubscriber.ancestors.include?(PpSql::LogSubscriberPrettyPrint)
          ActiveRecord::LogSubscriber.prepend(PpSql::LogSubscriberPrettyPrint)
        end
      end
    rescue LoadError => e
      warn "rails-sql-formatter: #{e.message}"
    end
  end
end

IRB.conf[:IRB_RC] = proc do |context|
  IRBHistoryPicker.activate!(context)
  RailsSqlFormatter.activate!
end
