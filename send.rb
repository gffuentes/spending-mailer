require 'erb'
require_relative 'endpoint.rb'

interp = ERB.new(File.read(File.expand_path('../template.html.erb',__FILE__)))
deliver(interp.result)