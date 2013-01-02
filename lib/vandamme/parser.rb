require 'open-uri'
require 'github/markup'

module Vandamme
  class Parser

    # Create a new changelog parser
    #
    # Options:
    # * +changelog+: uri of file to be parsed
    # * +version_header_exp+: regexp to match the starting line of version
    # * +format+: (optional). One of "raw", "markdown", "rdoc"
    #
    def initialize(options={})
      @changelog          = options.fetch :changelog
      @version_header_exp = Regexp.new(/#{options.fetch :version_header_exp}/)
      @format             = options[:format] || :raw
      @changelog_hash     = {}
    end

    # Parse changelog file, filling +@changelog_hash+ with
    # versions as keys, and version changelog as content.
    #
    def parse
      @changelog.scan(@version_header_exp) do
        version_content = $~.post_match
        changelog_scanner = StringScanner.new(version_content)
        changelog_scanner.scan_until(@version_header_exp)
        @changelog_hash[$1]= (changelog_scanner.pre_match || version_content).gsub(/^\n+/, '')
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
      # GitHub Markup API is really weird, we MUST pass a file name for format detection:
      @changelog_hash.inject({}) { |h,(k,v)| h[k] = GitHub::Markup.render(".#{@format}", v); h }
    end
  end
end
