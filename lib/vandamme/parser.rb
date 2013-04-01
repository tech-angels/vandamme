require 'open-uri'
require 'github/markup'

module Vandamme
  class Parser

    DEFAULT_REGEXP = Regexp.new('^#{1,2} ([\w\d\.-]+\.[\w\d\.-]+[a-z0-9]) ?\/? ?(\d{4}-\d{2}-\d{2}|\w+)?')

    # Create a new changelog parser
    #
    # Options:
    # * +changelog+:: Changelog content as a +String+.
    # * +version_header_exp+ (optional):: regexp to match the starting line of version.
    #   Defaults to /^#{1,2} ([\w\d\.-]+\.[\w\d\.-]+) ?\/? ?(\d{4}-\d{2}-\d{2}|\w+)?/
    #   See http://tech-angels.github.com/vandamme/#changelogs-convention
    # * +format+ (optional):: One of "raw", "markdown", "rdoc"
    #
    # 
    def initialize(options={})
      @changelog          = options.fetch :changelog
      regexp              = options[:version_header_exp] || DEFAULT_REGEXP
      @version_header_exp = regexp.is_a?(Regexp) ? regexp : Regexp.new(/#{regexp}/)
      @match_group        = options[:match_group] || 0
      @format             = options[:format] || :raw
      @changelog_hash     = {}
    end

    # call-seq:
    #   parse => aHash
    #
    # Parse changelog file, filling +@changelog_hash+ with
    # versions as keys, and version changelog as content.
    #
    def parse
      @changelog.scan(@version_header_exp) do |match|
        version_content = $~.post_match
        changelog_scanner = StringScanner.new(version_content)
        changelog_scanner.scan_until(@version_header_exp)
        @changelog_hash[match[@match_group]] = (changelog_scanner.pre_match || version_content).gsub(/(\A\n+|\n+\z)/, '')
      end
      @changelog_hash
    end

    # Convert @changelog_hash content to html using GitHub::Markup.
    # The +@format+ is used to determine the input format (should be one of:
    # "rdoc", "md", 'markdown", "raw", etc.)
    # See https://github.com/github/markup/blob/master/lib/github/markups.rb
    # for more formats. The corresponding gem must be bundled.
    def to_html
      self.parse if @changelog_hash.empty?
      # GitHub Markup API is really weird, we MUST pass a file name for format detection as 1st arg:
      @changelog_hash.inject({}) { |h,(k,v)| h[k] = GitHub::Markup.render(".#{@format}", v); h }
    end
  end
end
