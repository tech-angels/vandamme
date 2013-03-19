require 'open-uri'
require 'github/markup'

module Vandamme
  class Parser

    # Create a new changelog parser
    #
    # Options:
    # * +changelog+:: Changelog content as a +String+.
    # * +version_header_exp+:: regexp to match the starting line of version.
    # * +format+ (optional):: One of "raw", "markdown", "rdoc"
    #
    # 
    def initialize(options={})
      @changelog          = options.fetch :changelog
      regexp              = options.fetch :version_header_exp
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
