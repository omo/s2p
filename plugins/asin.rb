# A Liquid tag for Jekyll sites that allows embedding Gists and showing code for non-JavaScript enabled browsers and readers.
# by: Brandon Tilly
# Source URL: https://gist.github.com/1027674
# Post http://brandontilley.com/2011/01/31/gist-tag-for-jekyll.html
#
# Example usage: {% gist 1027674 gist_tag.rb %} //embeds a gist for this plugin

require 'asin'
require 'cgi'
require 'httpi'
require 'fileutils'

def read_rc
  key_id = nil
  secret_key_id = nil
  associate = nil
  eval(open(File.expand_path("~/.amazonrc")).read, binding)

  {
    :key_id => key_id,
    :secret_key_id => secret_key_id,
    :associate => associate
  }
end

ASIN::Configuration.configure do |config|
  rc = read_rc()
  config.secret         = rc[:secret_key_id]
  config.key            = rc[:key_id]
  config.associate_tag  = rc[:associate]
  config.host = 'ecs.amazonaws.jp'
end

HTTPI.adapter = :curb

module Jekyll
  class AmazonResultCache
    CACHE_DIR = "./.aisn"

    def initialize
      @result_cache = {}
      FileUtils::mkdir_p(CACHE_DIR)
    end

    def read_cache(code)
      path = File.join(CACHE_DIR, code)
      return nil unless File.exists?(path)
      File.open(path, "r") { |f| Marshal.load(f.read) }
    end

    def write_cache(code, obj)
      path = File.join(CACHE_DIR, code)
      File.open(path, "w") { |f| f.write(Marshal.dump(obj)) }
    end

    @@instance = AmazonResultCache.new

    def self.instance
      @@instance
    end

    def item_lookup(code)
      code = code.strip
      hit = read_cache(code)
      return hit if hit
      sleep(0.5)
      client = ASIN::Client.instance
      got = client.lookup(code)
      write_cache(code, got)
      got
    end

    private_class_method :new
  end

  class AsinTagBase < Liquid::Tag
    def initialize(tag_name, text, token)
      super
      @id, @description = text.split(",")
      @asin = AmazonResultCache.instance.item_lookup(@id)
    end

    def text
      #p @asin
      desc = @description ? CGI::escape(@description): nil
      (desc or @asin.first.item_attributes.title).strip
    end
  end

  class AsinTag < AsinTagBase
    def render(context)
      '<a href="%s">%s</a>' % [@asin.first.detail_page_url, CGI::unescape(text)]
    end
  end

  class AsinImgTag < AsinTagBase
    def render(context)
      url = @asin.first.detail_page_url
      image = @asin.first.large_image.url
      '<a href="%s"><img class="asin" src="%s" title="%s" /></a>' % [url, image, CGI::unescape(text)]
    ensure
      if $!
        print $!
        print $!.backtrace.join("\n"), "\n" 
      end
    end
  end
end

Liquid::Template.register_tag('asin', Jekyll::AsinTag)
Liquid::Template.register_tag('asin_img', Jekyll::AsinImgTag)
