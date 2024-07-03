# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::PublicationsController, type: :controller do
  let(:form) { double }
  let(:suject) { Hyrax::PublicationsController.new }
  let(:params) do
    {
      publication: {
        date_issued: '2023-07-03',
        creator: [
          'John, Doe, Emory University',
          'Jane, Smith, Emory University'
        ]
      }
    }
  end

  before do
    allow(form).to receive(:date_issued_year=)
    allow(form).to receive(:creator_last_first=)
    allow(subject).to receive(:params).and_return(params)
  end

  describe '#add_custom_facet_params' do
    it 'calls add_custom_date_issued_facet and add_custom_creator_facet' do
      expect(subject).to receive(:add_custom_date_issued_facet).with(form)
      expect(subject).to receive(:add_custom_creator_facet).with(form)

      subject.add_custom_facet_params(form)
    end
  end

  describe '#add_custom_date_issued_facet' do
    it 'sets the date_issued_year on the form' do
      expect(form).to receive(:date_issued_year=).with('2023')

      subject.add_custom_date_issued_facet(form)
    end
  end

  describe '#add_custom_creator_facet' do
    it 'sets the creator_last_first on the form' do
      expected_creators = ["Doe, John", "Smith, Jane"]
      expect(form).to receive(:creator_last_first=).with(expected_creators)

      subject.add_custom_creator_facet(form)
    end
  end
end
