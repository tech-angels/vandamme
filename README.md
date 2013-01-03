# Vandamme

[![Dependency Status](https://gemnasium.com/tech-angels/vandamme.png)](https://gemnasium.com/tech-angels/vandamme)
[![Build Status](https://travis-ci.org/tech-angels/vandamme.png?branch=master)](https://travis-ci.org/tech-angels/vandamme)

Vandamme is a changelog parser gem, used in the [Gemnasium project](https://gemnasium.com)

## Installation

Add this line to your application's Gemfile:

    gem 'vandamme'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vandamme

## Usage

The Parser initializer will use 3 options:

* **:changelog**: full raw content of the changelog file
* **:version_header_exp**: regexp to match the versions lines in changelog
* **:format** (*optional*): if you want to use the html converter, you must provide the original format of the changelog

## Examples

```ruby
require 'rubygems'
require 'vandamme'
require 'open-uri'
changelog = open('https://raw.github.com/flori/json/master/CHANGES').read
parser = Vandamme::Parser.new(changelog: changelog, version_header_exp: '\d{4}-\d{2}-\d{2} \((\d\.\d+\.\d+)\)', format: 'markdown')
parser.parse
```
will return a hash with each version as keys, and version content as value.
The hash can be converted to html (using the [github-markup](https://github.com/github/markup) gem):

```ruby
parser.to_html
```

Vandamme is bundled with Redcarpet by default (for markdown), you must add the necessary gems to your bundle if you want to handle more formats.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
