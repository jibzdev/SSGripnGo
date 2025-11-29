require 'net/http'
require 'json'

class PostcodeLookupService
  def initialize(postcode)
    @postcode = postcode.to_s.strip.upcase
  end

  def lookup
    return [] if @postcode.blank?

    provider_chain.each do |provider|
      next unless provider.available?

      results = provider.lookup
      return results if results.present?
    end

    []
  rescue StandardError => e
    Rails.logger.error("PostcodeLookupService failure: #{e.message}")
    []
  end

  private

  def provider_chain
    [
      Providers::GetAddress.new(@postcode, getaddress_api_key),
      Providers::OsPlaces.new(@postcode, os_places_api_key),
      Providers::IdealPostcodes.new(@postcode, ideal_postcodes_api_key),
      Providers::Nominatim.new(@postcode)
    ]
  end

  def getaddress_api_key
    ENV['POSTCODE_LOOKUP_API_KEY'] ||
      ENV['GETADDRESS_API_KEY'] ||
      Rails.application.credentials.dig(:getaddress, :api_key)
  end

  def os_places_api_key
    ENV['OS_PLACES_API_KEY'] || Rails.application.credentials.dig(:os_places, :api_key)
  end

  def ideal_postcodes_api_key
    ENV['IDEAL_POSTCODES_API_KEY'] || Rails.application.credentials.dig(:ideal_postcodes, :api_key)
  end

  module Providers
    class Base
      attr_reader :postcode

      def initialize(postcode, api_key = nil)
        @postcode = postcode
        @api_key = api_key
      end

      def available?
        true
      end

      private

      attr_reader :api_key

      def perform_request(uri, headers = {})
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.read_timeout = 5
          http.open_timeout = 5
          request = Net::HTTP::Get.new(uri, headers)
          http.request(request)
        end
      end

      def normalize_response(address_hash)
        address_hash.transform_values(&:presence).compact
      end
    end

    class GetAddress < Base
      ENDPOINT = 'https://api.getaddress.io/find'.freeze

      def available?
        api_key.present?
      end

      def lookup
        return [] unless available?

        uri = URI.parse("#{ENDPOINT}/#{URI.encode_www_form_component(postcode)}")
        uri.query = URI.encode_www_form(
          'api-key' => api_key,
          'expand' => 'true',
          'sort' => 'true'
        )

        response = perform_request(uri)
        return [] unless response.is_a?(Net::HTTPSuccess)

        payload = JSON.parse(response.body)
        (payload['addresses'] || []).map { |address| normalize(address, payload['postcode']) }.compact_blank
      rescue JSON::ParserError
        []
      end

      private

      def normalize(address, fallback)
        return if address.blank?

        line1 = address['line_1'].presence || build_line_one(address)
        line2 = address['line_2'].presence || join_parts(address['line_3'], address['line_4'], address['dependent_locality'])

        {
          line1: line1,
          line2: line2,
          city: address['town_or_city'] || address['post_town'],
          region: address['county'],
          postal_code: fallback || postcode,
          country: 'United Kingdom'
        }.transform_values(&:presence).compact
      end

      def build_line_one(address)
        join_parts(address['building_number'], address['sub_building_name'], address['building_name'], address['thoroughfare'])
      end

      def join_parts(*parts)
        parts.compact_blank.join(' ').squish.presence
      end
    end

    class OsPlaces < Base
      ENDPOINT = 'https://api.os.uk/search/places/v1/postcode'.freeze

      def available?
        api_key.present?
      end

      def lookup
        return [] unless available?

        uri = URI.parse(ENDPOINT)
        uri.query = URI.encode_www_form(postcode: postcode, key: api_key)

        response = perform_request(uri)
        return [] unless response.is_a?(Net::HTTPSuccess)

        payload = JSON.parse(response.body)
        (payload['results'] || []).map { |result| normalize(result['DPA']) }.compact_blank
      rescue JSON::ParserError
        []
      end

      private

      def normalize(dpa)
        return if dpa.blank?

        line1 = join_parts(dpa['BUILDING_NUMBER'], dpa['BUILDING_NAME'], dpa['THOROUGHFARE_NAME'])
        line2 = join_parts(dpa['DEPENDENT_THOROUGHFARE_NAME'], dpa['DEPENDENT_LOCALITY'], dpa['DOUBLE_DEPENDENT_LOCALITY'])

        {
          line1: line1,
          line2: line2,
          city: dpa['POST_TOWN'],
          region: dpa['COUNTY'],
          postal_code: dpa['POSTCODE'] || postcode,
          country: 'United Kingdom'
        }.transform_values(&:presence).compact
      end

      def join_parts(*parts)
        parts.compact_blank.join(' ').squish.presence
      end
    end

    class IdealPostcodes < Base
      ENDPOINT = 'https://api.ideal-postcodes.co.uk/v1/postcodes'.freeze

      def available?
        api_key.present?
      end

      def lookup
        return [] unless available?

        uri = URI.parse("#{ENDPOINT}/#{URI.encode_www_form_component(postcode)}")
        uri.query = URI.encode_www_form(api_key: api_key)

        response = perform_request(uri)
        return [] unless response.is_a?(Net::HTTPSuccess)

        payload = JSON.parse(response.body)
        (payload.dig('result') || []).map { |address| normalize(address) }.compact_blank
      rescue JSON::ParserError
        []
      end

      private

      def normalize(address)
        return if address.blank?

        {
          line1: address['line_1'],
          line2: address['line_2'],
          city: address['post_town'],
          region: address['county'],
          postal_code: address['postcode'] || postcode,
          country: 'United Kingdom'
        }.transform_values(&:presence).compact
      end
    end

    class Nominatim < Base
      ENDPOINT = 'https://nominatim.openstreetmap.org/search'.freeze

      def lookup
        uri = URI.parse(ENDPOINT)
        uri.query = URI.encode_www_form(
          postalcode: postcode,
          countrycodes: 'gb',
          format: 'json',
          addressdetails: 1,
          limit: 25
        )

        response = perform_request(uri, 'User-Agent' => user_agent)
        return [] unless response.is_a?(Net::HTTPSuccess)

        payload = JSON.parse(response.body)
        payload.map { |entry| normalize(entry['address'], entry['display_name']) }.compact_blank
      rescue JSON::ParserError
        []
      end

      private

      def normalize(address, fallback)
        return if address.blank? && fallback.blank?

        line1 = join_parts(address&.fetch('house_number', nil), address&.fetch('road', nil)) ||
                address&.fetch('residential', nil) ||
                fallback
        line2 = join_parts(address&.fetch('neighbourhood', nil), address&.fetch('suburb', nil))

        {
          line1: line1,
          line2: line2,
          city: address&.fetch('city', nil) || address&.fetch('town', nil) || address&.fetch('village', nil),
          region: address&.fetch('state_district', nil) || address&.fetch('state', nil),
          postal_code: address&.fetch('postcode', nil) || postcode,
          country: address&.fetch('country', nil) || 'United Kingdom'
        }.transform_values(&:presence).compact
      end

      def join_parts(*parts)
        parts.compact_blank.join(' ').squish.presence
      end

      def user_agent
        app_name = Rails.application.class.module_parent_name rescue 'SSGrip'
        "#{app_name}-PostcodeLookup/#{Rails.version}"
      end
    end
  end
end

