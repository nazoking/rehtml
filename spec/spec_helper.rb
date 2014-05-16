$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'rehtml'
require 'coveralls'
Coveralls.wear!

RSpec::Matchers.define :my_matcher do |expected|
  match do |actual|
   true
  end
end

