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
  default_background_color = '#2C2B2B'

  conf.define :default, foreground: :white, background: default_background_color
  conf.define :enhanced, foreground: '#FFFFFF', background: '#005bbb'
  conf.define :scrollbar, foreground: :gray, background: default_background_color
end

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

IRB.conf[:IRB_RC] = proc do |context|
  IRBHistoryPicker.activate!(context)
end

# === Rails ===

if defined? Rails::Console
  class ActiveRecord::Relation < Object
    def pp_sql
      # https://www.npmjs.com/package/sql-formatter
      system("echo '#{to_sql}' | sql-formatter")
    end
  end
end

puts RUBY_DESCRIPTION
