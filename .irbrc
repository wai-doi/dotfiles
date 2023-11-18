# `edit` command opens files in your editor
ENV['EDITOR'] = 'code'

IRB.conf[:INSPECT_MODE] = :pp

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

puts "Ruby v#{RUBY_VERSION}"

if Gem::Version.new(IRB::VERSION) >= Gem::Version.new('1.6')
  puts "The `\e[36mshow_cmds\e[0m` command prints all available IRB commands."
end

require 'csv'
require 'date'
require 'json'
require 'time'
require 'yaml'
