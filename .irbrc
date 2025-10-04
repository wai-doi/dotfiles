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
  # Monkey Patch Ctrl-R
  private def incremental_search_history(_key)
    # peco コマンドが存在しない場合はメッセージを表示して終了
    unless system('which peco > /dev/null 2>&1')
      puts "peco command not found. Please install peco from https://github.com/peco/peco"
      return
    end

    histories = Reline::HISTORY
      .reverse
      .uniq
      .map { |e| e.gsub(/\R/, '⏎ ') } # 改行を可視化
      .join("\n")

    code = IO.popen('peco', 'r+') { |io|
      # 履歴を peco に渡す
      io.write(histories)
      # CPU負荷軽減のために close_write する
      io.close_write
      # 選択されたコードを peco から受け取る
      io.gets(chomp: true)
    }

    # 選択されたコードをプロンプトにセット
    @buffer_of_lines = code ? code.split('⏎ ') : ['']
    # 最後の行に移動
    @line_index = @buffer_of_lines.length - 1
    # 最後の行の末尾に移動
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
