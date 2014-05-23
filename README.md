# REHTML

[![Build Status](https://travis-ci.org/nazoking/rehtml.png?branch=master)](https://travis-ci.org/nazoking/rehtml)
[![Coverage Status](https://coveralls.io/repos/nazoking/rehtml/badge.png?branch=master)](https://coveralls.io/r/nazoking/rehtml?branch=master)
[![Code Climate](https://codeclimate.com/github/nazoking/rehtml.png)](https://codeclimate.com/github/nazoking/rehtml)
[![Dependency Status](https://gemnasium.com/nazoking/rehtml.png)](https://gemnasium.com/nazoking/rehtml)

Pure Ruby html parser.

This library parse html and build rexml document.

Nokogiri is very convenient, but the installation is complex because it do I need to build a native library, it is not suitable for chef.

## Installation

Add this line to your application's Gemfile:

    gem 'rehtml'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rehtml

## Usage

```
doc = REHTML.to_rexml(open('https://github.com/nazoking/rehtml').read)
```

## Contributing

1. Fork it ( http://github.com/nazoking/rehtml/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
