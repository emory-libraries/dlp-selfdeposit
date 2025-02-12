# frozen_string_literal: true
# [Hyrax-overwrite-v5.0.0] - brought in to test out of box behavior as well as our own.
#   - Removes testing of description (not used)
#   - Alters publication_date to our preferred solr value
#   - Adds all of our fields starting at Line 71
require 'rails_helper'
RSpec.describe Hyrax::GoogleScholarPresenter do
  subject(:presenter) { described_class.new(work) }
  let(:work) { FactoryBot.valkyrie_create(:publication, title: 'On Moomins') }

  shared_examples('tests for a direct solr document value return') do |method_name, solr_field|
    describe "##{method_name}" do
      let(:work) { FactoryBot.valkyrie_create(:publication, "#{solr_field}": 'test string') }

      it 'returns the expected string' do
        expect(presenter.send(method_name)).to eq 'test string'
      end
    end
  end

  describe '#scholarly?' do
    it { is_expected.to be_scholarly }

    context 'when the decorated object says it is not scholarly' do
      let(:work) { double('scholarly?': false) }

      it { is_expected.not_to be_scholarly }
    end
  end

  describe '#authors' do
    let(:work) { FactoryBot.valkyrie_create(:publication, creator: ['Tove', 'Lars']) }

    it 'gives an array of the authors' do
      expect(presenter.authors).to eq ['Tove', 'Lars']
    end

    context 'if the object provides ordered authors' do
      let(:work) { double(ordered_authors: ['Tove', 'Lars']) }

      it 'gives an array of the authors' do
        expect(presenter.authors).to eq ['Tove', 'Lars']
      end
    end
  end

  describe '#keywords' do
    let(:work) { FactoryBot.valkyrie_create(:publication, keyword: ['one', 'two', 'three']) }

    it 'lists the keywords semicolon delimeted' do
      expect(presenter.keywords).to eq 'one; two; three'
    end
  end

  describe '#publisher' do
    let(:work) { FactoryBot.valkyrie_create(:publication, publisher: ['Knopf', 'Macmillan', 'Sage']) }

    it 'lists the publishers semicolon delimeted' do
      expect(presenter.publisher).to eq 'Knopf; Macmillan; Sage'
    end
  end

  describe '#title' do
    it 'gives title as a string' do
      expect(presenter.title).to eq 'On Moomins'
    end
  end

  [
    ['publication_date', :date_issued_year],
    ['journal_title', :parent_title],
    ['conference_title', :conference_name],
    ['issn', :issn],
    ['isbn', :isbn],
    ['volume', :volume],
    ['issue', :issue],
    ['firstpage', :page_range_start],
    ['lastpage', :page_range_end]
  ].each do |method_name, solr_method_name|
    include_examples('tests for a direct solr document value return', method_name, solr_method_name)
  end
end
