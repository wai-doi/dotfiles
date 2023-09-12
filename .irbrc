# `edit` command opens files in your editor
ENV['EDITOR'] = 'code'

IRB.conf[:INSPECT_MODE] = :pp
IRB.conf[:USE_AUTOCOMPLETE] = false

puts "Ruby v#{RUBY_VERSION}"

if Gem::Version.new(IRB::VERSION) >= Gem::Version.new('1.6')
  puts "The `\e[36mshow_cmds\e[0m` command prints all available IRB commands."
end

require 'csv'
require 'date'
require 'json'
require 'time'
require 'yaml'
