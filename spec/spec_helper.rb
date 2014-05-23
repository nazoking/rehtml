$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'rehtml'
begin
  require 'coveralls'
  Coveralls.wear!
rescue LoadError
end

require 'rspec/expectations'


