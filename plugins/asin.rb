# A Liquid tag for Jekyll sites that allows embedding Gists and showing code for non-JavaScript enabled browsers and readers.
# by: Brandon Tilly
# Source URL: https://gist.github.com/1027674
# Post http://brandontilley.com/2011/01/31/gist-tag-for-jekyll.html
#
# Example usage: {% gist 1027674 gist_tag.rb %} //embeds a gist for this plugin

require 'amazon/aws'
require 'amazon/aws/search'
require 'cgi'

module Jekyll
  class AmazonResultCache
    def initialize
      @result_cache = {}
    end

    @@instance = AmazonResultCache.new

    def self.instance
      @@instance
    end

    def item_lookup(asin)
      asin.strip!
      return @result_cache[asin] if @result_cache.has_key?(asin)
      il = Amazon::AWS::ItemLookup.new('ASIN', {'ItemId' => asin})
      resp = Amazon::AWS::Search::Request.new.search(il)
      @result_cache[asin] = resp
      return resp
    end

    private_class_method :new
  end

  class AsinTagBase < Liquid::Tag
    def initialize(tag_name, text, token)
      super
      @id, @description = text.split(",")
      resp = AmazonResultCache.instance.item_lookup(@id)
      @item = resp.item_lookup_response[0].items[0].item[0]
    end
    def text
      (@description or @item.item_attributes.title.to_s).strip
    end
  end

  class AsinTag < AsinTagBase
    def render(context)
      url = @item.detail_page_url.to_s
      '<a href="%s">%s</a>' % [url, CGI::unescape(text)]
    end
  end
  
  class AsinImgTag < AsinTagBase
    def render(context)
      url = @item.detail_page_url.to_s
      image = @item.image_sets.image_set[0].large_image.url
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
