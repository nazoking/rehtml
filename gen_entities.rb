# -*- encoding: utf-8 -*-
require 'json'
require 'open-uri'
require 'kconv'

url = "http://www.w3.org/TR/html5/entities.json"
fname = File.join(File.dirname(__FILE__),"lib/rehtml/entities.rb")

puts "Generete #{fname} from #{url}"

# read
json = JSON.parse(open(url).read).delete_if{|k,v|
  k !~ /;$/
}

# write source
entities = json.map{|k,v|
 "\"#{k.gsub(/^&/,'').gsub(/;$/,'')}\" => #{v["codepoints"].inspect}.pack( \"U*\" )"
}
max_size = json.keys.map{|a|a.length}.max
open(fname,"w"){|f|
  f.write <<-CODE
module REHTML
  module ENTITIES
    # generate from #{url} on #{Time.now}
    MAP = {
      #{entities.join(",\n      ")}
    }
    REGEXP = /\\&(?:([a-zA-Z][a-zA-Z0-9]{1,#{max_size-1}})|#([0-9]{1,7})|#x([0-9a-f]{1,6}));/
  end
end
CODE
}

# check
require fname
json.keys.map{|m|
  puts "#{m} is not match #{REHTML::ENTITIES::REGEXP}" if m !~ REHTML::ENTITIES::REGEXP
}
puts "done."
