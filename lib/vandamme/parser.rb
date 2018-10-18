require 'open-uri'
require 'github/markup'
require 'vandamme/monkey_patch_markup'

module Vandamme
  class Parser

    DEFAULT_REGEXP = Regexp.new('^#{0,3} ?([\w\d\.-]+\.[\w\d\.-]+[a-zA-Z0-9])(?: \W (\w+ \d{1,2}(?:st|nd|rd|th)?,\s\d{4}|\d{4}-\d{2}-\d{2}|\w+))?\n?[=-]*')

    # Create a new changelog parser
    #
    # Options:
    # * +changelog+:: Changelog content as a +String+.
    # * +version_header_exp+ (optional):: regexp to match the starting line of version.
    #   Defaults to /^#{0,3} ?([\w\d\.-]+\.[\w\d\.-]+[a-zA-Z0-9])(?: \/ (\w+ \d{1,2}(?:st|nd|rd|th)?,\s\d{4}|\d{4}-\d{2}-\d{2}|\w+))?\n?[=-]*/
    #   See http://tech-angels.github.com/vandamme/#changelogs-convention
    # * +format+ (optional):: One of "raw", "markdown", "rdoc"
    # * +match_group+ (optional):: A number to say which match group to use as key
    # * +custom_hash_filler+ (optional):: A Proc that receives a hash, the regex match and content
    #   and should fill the hash with custom content (another hash)
    # 
    def initialize(options={})
      if options[:match_group] && options[:custom_hash_filler]
        raise ArgumentError, "only one of match_group or custom_hash_filler should be given"
      end

      @changelog          = options.fetch :changelog
      regexp              = options[:version_header_exp] || DEFAULT_REGEXP
      @version_header_exp = regexp.is_a?(Regexp) ? regexp : Regexp.new(/#{regexp}/)
      @match_group        = options[:match_group] || 0
      @format             = options[:format] || :raw
      @custom_hash_filler = options[:custom_hash_filler]
      @changelog_hash     = {}
    end

    # call-seq:
    #   parse => aHash
    #
    # Parse changelog file, filling +@changelog_hash+ with
    # versions as keys, and version changelog as content.
    #
    # When a block is given, yield the changelog hash, match and content.
    # It's up to the caller to fill the hash as they see fit.
    #
    def parse
      @changelog.scan(@version_header_exp) do |match|
        version_content = $~.post_match
        changelog_scanner = StringScanner.new(version_content)
        changelog_scanner.scan_until(@version_header_exp)
        content = (changelog_scanner.pre_match || version_content).gsub(/(\A\n+|\n+\z)/, '')
        if @custom_hash_filler
          @custom_hash_filler.call(@changelog_hash, match, content)
        else
          @changelog_hash[match[@match_group]] = content
        end
      end
      @changelog_hash
    end

    # Convert @changelog_hash content to html using GitHub::Markup.
    # The +@format+ is used to determine the input format (should be one of:
    # "rdoc", "md", 'markdown", "raw", etc.)
    # See https://github.com/github/markup/blob/master/lib/github/markups.rb
    # for more formats. The corresponding gem must be bundled.
    #
    # If the @changelog_hash is not just key -> String(content), a block must be provided
    # that can get the string content from the custom content. For example,
    # if the content is a hash like { date: '2017-09-19', content: '* Things' }, calling
    # to_html { |hash| hash[:content] } will render "<ul><li>Things</li></ul>"
    def to_html
      self.parse if @changelog_hash.empty?
      @changelog_hash.each_with_object({}) do |(k, v), h|
        value = block_given? ? yield(v) : v
        # GitHub Markup API is really weird, we MUST pass a file name for format detection as 1st arg:
        h[k] = GitHub::Markup.render(".#{@format}", value)
      end
    end
  end
end
