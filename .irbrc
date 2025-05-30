# `edit` command opens files in your editor
ENV['EDITOR'] = 'code'

IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:INSPECT_MODE] = :pp
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:COMPLETOR] = :type

if Gem::Version.new(Reline::VERSION) >= Gem::Version.new('0.4.0')
  Reline::Face.config(:completion_dialog) do |conf|
    # Slightly lighter black than :black ('#222121')
    default_background_color = '#2C2B2B'

    conf.define :default, foreground: :white, background: default_background_color
    conf.define :enhanced, foreground: '#FFFFFF', background: '#005bbb'
    conf.define :scrollbar, foreground: :gray, background: default_background_color
  end
else
  # Disable auto completion because completion text is difficult to see.
  IRB.conf[:USE_AUTOCOMPLETE] = false
end

def safe_require(lib_name)
  require lib_name
rescue LoadError
end

safe_require 'csv'
safe_require 'date'
safe_require 'json'
safe_require 'time'
safe_require 'yaml'

# === Reline ===

class Reline::LineEditor
  private def incremental_search_history(_key)
    # Monkey Patch Ctrl-R
    # https://github.com/peco/peco
    code = IO.popen('peco', 'r+') { |io|
      io.puts Reline::HISTORY.reverse.uniq
      io.gets
    }
    @buffer_of_lines = code ? code.split("\n") : ['']
    @byte_pointer = current_line.bytesize
  end
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
