# Vandamme

[![Dependency Status](https://gemnasium.com/tech-angels/vandamme.png)](https://gemnasium.com/tech-angels/vandamme)
[![Build Status](https://travis-ci.org/tech-angels/vandamme.png?branch=master)](https://travis-ci.org/tech-angels/vandamme)

Vandamme is a changelog parser gem, used in the [Gemnasium](https://gemnasium.com) project.

There are thousands of different changelogs (if any) out there, with dozens of different names. 
It's almost impossible to fetch and parse them automatically... Gemnasium is using Vandamme to 
keep each changelog specificities (changelog location, version format, file format).

We really believe in changelogs. Following changes in dependencies is a hard task, and almost impossible
by reading commits only.

The opensource world would be so much nicer with full, readable and comprehensive changelogs. 
As a solution to this problem, we propose a simple set of rules and requirements to follow in order to have a 
Standard Changelog. Please see the [Changelogs Convention](#changelogs-convention) section below.

Stay aware of changes!

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
* **:format** (*optional*): if you want to use the html converter, you must provide the original format of the changelog. (default: 'raw')
* **:group_match** (*optional*): Number of the match group is used for version matching. (default: 0)

### Regex format

**version_header_exp** will be converted to a new Regex object if it wasn't one.
Therefore, 

    Vandamme::Parser.new(changelog: changelog, version_header_exp: '(\d\.\d+\.\d+) \((\d{4}-\d{2}-\d{2})\)?')

is equivalent to:

    Vandamme::Parser.new(changelog: changelog, version_header_exp: /(\d\.\d+\.\d+) \(\d{4}-\d{2}-\d{2}\)?/)

Be careful with how ruby is handling escaped caracters in a string: ```"\d"``` if different from ```'\d'```!

### Version Matching

By default, the first match of the Regexp will be considered as the version number.
ie:

    'Release (\d+\.\d+\.\d+)'

will match lines like:

    Release 1.3.5

and '1.3.5' will be used as a key in the Hash returned by the ```parse``` method.
Starting Vandamme 0.0.2, it's possible to specify which match group must be
used for the version number, by passing the option **:match_group** to the
initializer:

    Vandamme::Parser.new([...], :matching_group => 1)

The default match group is 0: this is the first group matched (0 being the
original string), because we are using ```String#scan``` instead of ```Regexp.match```.


## Examples

```ruby
require 'rubygems'
require 'vandamme'
require 'open-uri'
changelog = open('https://raw.github.com/flori/json/master/CHANGES').read
parser = Vandamme::Parser.new(changelog: changelog, version_header_exp: '(\d\.\d+\.\d+) \(\d{4}-\d{2}-\d{2}\)', format: 'markdown')
parser.parse
```
will return a hash with each version as keys, and version content as value.
The hash can be converted to html (using the [github-markup](https://github.com/github/markup) gem):

```ruby
parser.to_html
```

Vandamme is bundled with Redcarpet by default (for markdown), you must add the necessary gems to your bundle if you want to handle more formats.

## Changelogs Convention

### Filename

+ Your changelog file **MUST** be named CHANGELOG.format (preferably ```CHANGELOG.md```)
+ Your changelog file **MUST** be at the root of your project
+ You **MAY** have different changelog in each branch (like [Ruby on Rails](https://github.com/rails/rails))

### Format

+ Your changelog **MUST** be in plain text formatting syntax. 
+ You **MUST** use one the supported markup: https://github.com/github/markup#markups 
+ You **MAY** prefer Markdown (.md) is now the most popular format for READMEs on Github, let's stick to it.
+ Your changelog **MUST** follow the format:

```
LEVEL 1 (or 2) HEADER WITH VERSION AND RELEASE DATE

VERSION CHANGES

LEVEL 1 (or 2) HEADER WITH VERSION AND RELEASE DATE

VERSION CHANGES

[...]
```

Example in Markdown: 

```markdown
# 1.2.4 / Unreleased

* Fix bug #2

# 1.2.3 / 2013-02-14

* Update API 
* Fix bug #1
```

+ LEVEL 1 (or 2) HEADER WITH VERSION **MUST** at least contain the version number (```{{version_number}}```)
+ If the release date is present, it **MUST** follow the form ```{{version_number}} / {{release_date}}```
+ {{release_date}} is optional but  if present it **MUST** follow one of these formats:
++ the full english style format: "December 14th, 2014" (ordinal suffix is optional)
++ the ISO 8601 format: "YYYY-MM-DD"
++ the text "Unreleased"
+ VERSION CHANGES **MAY** contain more levels, but MUST follow the markup syntax.
+ {{version_number}} **SHOULD** follow the [semver](http://semver.org/) convention.
+ {{version_number}} **MUST** contain at least a dot (ex: "1.2").

### Keywords

Usage of keywords is strongly recommanded, as it helps to identify the nature of each change.
Keywords should be a one-word tag, in caps, preceding each change line:

```markdown
# 1.2.4 / Unreleased

* [BUGFIX] Fix bug #2
* [FEATURE] Add github oauth login
* [PERFORMANCE] Now 25% faster!
```

+ Keyword, if present, **MUST** be in caps, at beginning of line, and surrounded with square brackets.
+ Keyword **SHOULD** be preferably among: "SECURITY", "BUGFIX", "FEATURE", "ENHANCEMENT", "PERFORMANCE"


### Note

Changelogs following these rules will be automatically included in Gemnasium.
The regexp used is 

```
^#{0,3} ?([\w\d\.-]+\.[\w\d\.-]+[a-zA-Z0-9])(?: \/ (\w+ \d{1,2}(?:st|nd|rd|th)?,\s\d{4}|\d{4}-\d{2}-\d{2}|\w+))?\n?[=-]*
```

Check your changelog using Rubular if you want to be sure:
http://rubular.com/r/Gw6rIS5HkJ

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

  Philippe Lafoucrière @ Tech-angels - http://www.tech-angels.com/

  [![Tech-Angels](http://media.tumblr.com/tumblr_m5ay3bQiER1qa44ov.png)](http://www.tech-angels.com)

