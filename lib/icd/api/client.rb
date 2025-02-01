# frozen_string_literal: true

require 'icd/api/version'
require 'icd/api/options'
require 'icd/api/connection'
require 'icd/api/entity'

require 'faraday'
require 'json'

module Icd
  module Api
    class Client
      def initialize(client_id:, client_secret:, **options)
        @client_id = client_id
        @client_secret = client_secret
        @options = Options.new(options)
      end

      def search(term)
        response = connection.get('search',
                                  {
                                    q: term,
                                    **api_default_params
                                  })

        response.body['destinationEntities'].map do |entity|
          Entity.new(entity)
        end
      end

      def fetch_parent_stem_by_code(code)
        stem_id = fetch_stem_id_by_code(code, alive: true)
        stem_info = fetch_info_by_stem_id(stem_id, alive: true)
        stem_info_h = JSON.parse(stem_info)
        stem_info_h['parent']
      end

      def fetch_top_level_parent_by_code(code)
        last_parent = ''
        next_parent = fetch_parent_stem_by_code(code, alive: true)[0]

        stem_code = next_parent.partition('mms')[1]
        loop do
          break if stem_code == 'mms'

          last_parent = next_parent
          stem_info = fetch_info_by_stem_id(last_parent, alive: true)
          stem_info_h = JSON.parse(stem_info)
          next_parent = fetch_parent_stem_by_code(stem_info_h['code'], alive: true)[0]
          stem_code = next_parent.partition('mms')[1]
        end

        last_parent
      end

      def fetch_stem_id_by_code(code, alive: false)
        response = if alive == true
                     alive_connection.get("codeinfo/#{code}", { flexiblemode: 'false' })
                   else
                     connection.get("codeinfo/#{code}", { flexiblemode: 'false' })
                   end
        response.body['stemId']
      end

      def fetch_info_by_stem_id(stem_id, alive: false)
        entity_id = parse_entity_id(stem_id)
        response = if alive == true
                     alive_connection.get(entity_id, {})
                   else
                     connection.get(entity_id, {})
                   end

        response.body
      end

      private

      def api_default_params
        { subtreeFilterUsesFoundationDescendants: 'false',
          includeKeywordResult: 'true',
          useFlexisearch: 'false',
          flatResults: 'false',
          highlightingEnabled: 'false',
          includePostcoordination: 'true' }
      end

      def alive_connection
        @options.alive = true
        @alive_connection ||= Connection.new(@client_id, @client_secret, @options)
      end

      def connection
        Connection.new(@client_id, @client_secret, @options)
      end

      def parse_entity_id(stem_id)
        entity_id = stem_id.split('/').last
        entity_id = stem_id.split('/')[-2] if entity_id == 'unknown'

        entity_id
      end
    end
  end
end
