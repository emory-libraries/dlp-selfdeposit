# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
  subject(:document) { described_class.new(attributes) }
  let(:attributes) { {} }
  multiple_valued_fields = described_class::METHOD_ASSIGNMENTS.select { |_k, v| v.last == 'm' }
  single_valued_fields = described_class::METHOD_ASSIGNMENTS.dup - multiple_valued_fields

  shared_examples('tests for a direct solr index value return') do |method_name, solr_field, val|
    describe "##{method_name}" do
      let(:attributes) { { "#{solr_field}": [val] } }

      it 'returns the value from the solr document index' do
        expect(document.send(method_name)).to eq attributes[solr_field.to_sym]
      end
    end
  end

  multiple_valued_fields.each do |method_name, solr_field|
    include_examples('tests for a direct solr index value return', method_name, solr_field, ["test string", "another string", "last string"])
  end

  single_valued_fields.each do |method_name, solr_field|
    include_examples('tests for a direct solr index value return', method_name, solr_field, "test string")
  end

  include_examples('tests for a direct solr index value return',
                   'system_of_record_ID',
                   'system_of_record_ID_ssi',
                   '12345678-cor')
end
