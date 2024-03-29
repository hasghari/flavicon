# frozen_string_literal: true

module Flavicon
  class Finder
    require 'uri'
    require 'net/http'
    require 'nokogiri'

    TooManyRedirects = Class.new(StandardError)

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def find
      response, resolved = request(url)

      extract_from_html(response.body, resolved)
        .push(default_path(resolved))
        .find { |url| verify_favicon_url(url) }
    end

    def verify_favicon_url(url)
      response, resolved = request(url)
      return unless response.is_a?(Net::HTTPSuccess) && response.body.to_s != '' && response.content_type =~ /image/i

      resolved
    end

    def extract_from_html(html, url)
      Nokogiri::HTML(html).css('head link').filter_map do |node|
        URI.join(url, node[:href]).to_s if node[:rel] =~ /\A(shortcut )?icon\z/i
      end
    end

    def default_path(url)
      URI.join(url, '/favicon.ico').to_s
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def request(url, limit = 10)
      raise TooManyRedirects if limit.negative?

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
        [response, url]
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    # While the soon-to-be obsolete IETF standard RFC 2616 (HTTP 1.1) requires a complete absolute URI for redirection,
    # the most popular web browsers tolerate the passing of a relative URL as the value for a Location header field.
    # Consequently, the current revision of HTTP/1.1 makes relative URLs conforming.
    def extract_location(response, url)
      URI.join(url, response['location']).to_s
    end
  end
end
