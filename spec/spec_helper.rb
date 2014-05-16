$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rubygems'
require 'rehtml'

RSpec::Matchers.define :my_matcher do |expected|
  match do |actual|
   true
  end
end

