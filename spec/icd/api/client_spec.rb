# frozen_string_literal: true

require 'spec_helper'
RSpec.describe Icd::Api::Client do
  let(:language) { nil }
  let(:client) { described_class.new(client_id: '', client_secret: '', language:) }

  context 'Fetch by Code -- Good Value' do
    let(:response) do
      VCR.use_cassette('by_code_FB32.5') { client.fetch_stem_id_by_code('FB32.5') }
    end

    it 'returns required fields' do
      expect(response).to eq('http://id.who.int/icd/release/11/2022-02/mms/254923627')
    end
  end

  context 'Fetch by Code in French' do
    let(:language) { :fr }
    let(:response) do
      VCR.use_cassette('by_code_FB32.5_fr') { client.fetch_stem_id_by_code('FB32.5') }
    end

    it 'returns required fields' do
      expect(response).to eq('http://id.who.int/icd/release/11/2022-02/mms/254923627')
    end
  end

  context 'Fetch parent by code' do
    let(:stem_id) do
      VCR.use_cassette('by_code_7A01') { client.fetch_stem_id_by_code('7A01') }
    end

    let(:stem_info) do
      VCR.use_cassette('by_stemId_1832877760') { client.fetch_info_by_stem_id(stem_id) }
    end

    let(:response) do
      VCR.use_cassette('parent_by_code_7A01') { client.fetch_parent_stem_by_code('7A01') }
    end

    it 'returns stemId information' do
      expect(stem_id).to eq('http://id.who.int/icd/release/11/2023-01/mms/1832877760')
    end

    it 'have the parent info inside initial fetch info' do
      stem_info_h = JSON.parse(stem_info)
      expect(stem_info_h['parent']).to eq(['http://id.who.int/icd/release/11/2023-01/mms/1038292737'])
    end

    it 'have the code of current fetch from stem id' do
      stem_info_h = JSON.parse(stem_info)
      expect(stem_info_h['code']).to eq('7A01')
    end

    it 'returns the parent stemId' do
      expect(response[0]).to eq('http://id.who.int/icd/release/11/2023-01/mms/1038292737')
    end
  end

  context 'Fetch top level parent by code' do
    let(:response) do
      VCR.use_cassette('toplevel_parent_by_code_7A01') { client.fetch_stem_id_by_code('7A01') }
    end

    it 'returns expected stemid' do
      expect(response).to eq('274880002')
    end
  end

  context 'Fetch by Code -- Deprecated' do
    let(:response) do
      VCR.use_cassette('by_code_1F4Z') { client.fetch_stem_id_by_code('1F4Z') }
    end

    let(:stem_id_response) do
      stem_id = response.rpartition('/')[0]
      VCR.use_cassette('by_stemId_1439886552') { client.fetch_info_by_stem_id(stem_id) }
    end

    it 'returns string including unspecified' do
      expect(response).to eq('http://id.who.int/icd/release/11/2022-02/mms/1439886552/unspecified')
    end

    it 'returns information on the parent' do
      expect(stem_id_response['@id']).to eq('http://id.who.int/icd/release/11/2022-02/mms/1439886552')
      expect(stem_id_response['title']['@value']).to eq('Malaria')
    end
  end
end
