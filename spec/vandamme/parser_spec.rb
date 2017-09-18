require 'spec_helper'

describe Vandamme::Parser do
  context "with json gem changelog" do
    let(:changelog_file) { File.read("spec/fixtures/json.md") }
    let(:changelog_as_hash) {
      {
        "1.7.6"=> "  * Add GeneratorState#merge alias for JRuby, fix state accessor methods. Thx to\n   jvshahid@github.\n  * Increase hash likeness of state objects.",
        "1.7.5"=> "  * Fix compilation of extension on older rubies.",
        "1.7.4"=> "  * Fix compilation problem on AIX, see https://github.com/flori/json/issues/142"
      }
    }

    let(:changelog_as_html_hash) {
      {
        "1.7.6"=> "<ul>\n<li>Add GeneratorState#merge alias for JRuby, fix state accessor methods. Thx to\njvshahid@github.</li>\n<li>Increase hash likeness of state objects.</li>\n</ul>\n",
        "1.7.5"=> "<ul>\n<li>Fix compilation of extension on older rubies.</li>\n</ul>\n",
        "1.7.4"=> "<ul>\n<li>Fix compilation problem on AIX, see <a href=\"https://github.com/flori/json/issues/142\">https://github.com/flori/json/issues/142</a></li>\n</ul>\n"
      }
    }

    before do
      @parser = Vandamme::Parser.new(changelog: changelog_file, version_header_exp: '\d{4}-\d{2}-\d{2} \((\d\.\d+\.\d+)\)', format: 'markdown')
      @changelog_parsed = @parser.parse
    end

    it "should parse file and fill changelog hash" do
      expect(@changelog_parsed).to eq(changelog_as_hash)
    end

    it "should provide html content" do
      expect(@parser.to_html).to eq(changelog_as_html_hash)
    end
  end

  context "with postmark-gem changelog (rdoc)" do
    let(:changelog_file) { File.read("spec/fixtures/postmark-gem.rdoc") }
    let(:changelog_as_hash) {
      {
        "0.9.15" => "* Save a received MessageID in message headers.",
        "0.9.14" => "* Parse Subject and MessageID from the Bounce API response.",
        "0.9.13" => "* Added error_code to DeliveryError\n* Added retries for Timeout::Error",
        "0.9.12" => "* Fixed a problem of attachments processing when using deliver! method on Mail object.\n* Removed activesupport dependency for Postmark::AttachmentsFixForMail.\n* Added specs for AttachmentFixForMail.",
        "0.9.11" => "* Replaced Jeweler by Bundler.\n* Updated RSpec to 2.8.\n* Fixed specs.\n* Refactored the codebase."
      }
    }

    let(:changelog_as_html_hash) {
      {
        "0.9.15" => "<ul><li>\n<p>Save a received MessageID in message headers.</p>\n</li></ul>\n",
        "0.9.14" => "<ul><li>\n<p>Parse Subject and MessageID from the Bounce API response.</p>\n</li></ul>\n",
        "0.9.13" => "<ul><li>\n<p>Added error_code to DeliveryError</p>\n</li><li>\n<p>Added retries for Timeout::Error</p>\n</li></ul>\n",
        "0.9.12" => "<ul><li>\n<p>Fixed a problem of attachments processing when using deliver! method on\nMail object.</p>\n</li><li>\n<p>Removed activesupport dependency for Postmark::AttachmentsFixForMail.</p>\n</li><li>\n<p>Added specs for AttachmentFixForMail.</p>\n</li></ul>\n",
        "0.9.11" => "<ul><li>\n<p>Replaced Jeweler by Bundler.</p>\n</li><li>\n<p>Updated RSpec to 2.8.</p>\n</li><li>\n<p>Fixed specs.</p>\n</li><li>\n<p>Refactored the codebase.</p>\n</li></ul>\n"
      }
    }

    before do
      @parser = Vandamme::Parser.new(changelog: changelog_file, version_header_exp: '== (\d.\d+\.\d+)', format: 'rdoc')
      @changelog_parsed = @parser.parse
    end

    it "should parse file and fill changelog hash" do
      expect(@changelog_parsed).to eq(changelog_as_hash)
    end

    it "should provide html content" do
      expect(@parser.to_html).to eq(changelog_as_html_hash)
    end
  end

  context "with changelog changing convention (md)" do
    let(:changelog_file) { 
      <<-eos
# Version 1.0.0 - 2013-01-06

* First stable version.

# Release 0.9.9

* Last Beta before stable.
      eos
      }
    let(:changelog_as_hash) {
      {
        "1.0.0" => "* First stable version.",
        "0.9.9" => "* Last Beta before stable."
      }
    }

    let(:changelog_as_html_hash) {
      {
        "1.0.0" => "<ul>\n<li>First stable version.</li>\n</ul>\n",
        "0.9.9" => "<ul>\n<li>Last Beta before stable.</li>\n</ul>\n"
      }
    }

    before do
      @parser = Vandamme::Parser.new(changelog: changelog_file, version_header_exp: '# (Version|Release) (\d.\d+\.\d+)( - \d{4}-\d{2}-\d{2})?', format: 'md', match_group: 1)
      @changelog_parsed = @parser.parse
    end

    it "should parse file and fill changelog hash" do
      expect(@changelog_parsed).to eq(changelog_as_hash)
    end

    it "should provide html content" do
      expect(@parser.to_html).to eq(changelog_as_html_hash)
    end
  end

  context "Changelog Convention default regexp" do
    # The convention now accepts level 2 headers
    # and an optional release date:
    let(:changelog_file) { 
      <<-eos
# X.Y.Z / Unreleased

* Update API 
* Fix bug #1

## 1.2.3-pre.1 / 2013-02-14

* Update API 

## 1.2.2 / December 3, 2014

* Add something else

## 1.2.1 / December 1st, 2014

* Add something

# 1.0.0-x.7.z.92
      eos
      }

    let(:changelog_as_hash) {
      {
        "X.Y.Z"           => "* Update API \n* Fix bug #1",
        "1.2.3-pre.1"     => "* Update API ",
        "1.2.2"           => "* Add something else",
        "1.2.1"           => "* Add something",
        "1.0.0-x.7.z.92"  => ""
      }
    }


    before do
      @parser = Vandamme::Parser.new(changelog: changelog_file)
      @changelog_parsed = @parser.parse
    end

    it "should parse file and fill changelog hash" do
      expect(@changelog_parsed).to eq(changelog_as_hash)
    end
  end

  context "Alternative markdown headers syntax" do
    let(:changelog_file) { 
      <<-eos
Changelog
=========

X.Y.Z / Unreleased
------------------

* Update API 
* Fix bug #1

1.2.3-pre.1 / 2013-02-14
------------------------

* Update API 

1.0.0-x.7.z.92
--------------
      eos
      }

    let(:changelog_as_hash) {
      {
        "X.Y.Z"           => "* Update API \n* Fix bug #1",
        "1.2.3-pre.1"     => "* Update API ",
        "1.0.0-x.7.z.92"  => ""
      }
    }


    before do
      @parser = Vandamme::Parser.new(changelog: changelog_file)
      @changelog_parsed = @parser.parse
    end

    it "should parse file and fill changelog hash" do
      expect(@changelog_parsed).to eq(changelog_as_hash)
    end
  end
end
