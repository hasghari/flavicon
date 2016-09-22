module Flavicon
  class Finder < Struct.new(:url)
    require 'uri'
    require 'net/http'
    require 'nokogiri'

    TooManyRedirects = Class.new(StandardError)

    def find
      response, resolved = request(url)
      favicon_url = extract_from_html(response.body, resolved) || default_path(resolved)
      verify_favicon_url(favicon_url)
    end

    def verify_favicon_url(url)
      response, resolved = request(url)
      return unless response.is_a?(Net::HTTPSuccess) && response.body.to_s != '' && response.content_type =~ /image/i
      resolved
    end

    def extract_from_html(html, url)
      link = Nokogiri::HTML(html).css('head link').find do |link|
        link[:rel] =~ /\A(shortcut )?icon\z/i
      end

      URI.join(url, link[:href]).to_s if link
    end

    def default_path(url)
      URI.join(url, '/favicon.ico').to_s
    end

    def request(url, limit = 10)
      raise TooManyRedirects if limit < 0

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(request)

      if response.is_a? Net::HTTPRedirection
        request(extract_location(response, url), limit - 1)
      else
        return response, url
      end
    end

    # While the soon-to-be obsolete IETF standard RFC 2616 (HTTP 1.1) requires a complete absolute URI for redirection,
    # the most popular web browsers tolerate the passing of a relative URL as the value for a Location header field.
    # Consequently, the current revision of HTTP/1.1 makes relative URLs conforming.
    def extract_location(response, url)
      URI.join(url, response['location']).to_s
    end
  end
end
