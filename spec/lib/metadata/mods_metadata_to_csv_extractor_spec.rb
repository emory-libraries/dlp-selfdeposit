# frozen_string_literal: true

require 'rails_helper'
require './lib/metadata/mods_metadata_to_csv_extractor'

RSpec.describe ModsMetadataToCsvExtractor, :clean do
  let(:pids_filenames_csv_path) { fixture_path + '/csv/pids_with_binaries_20240730T1051.csv' }
  let(:extractor) { described_class.new(csv_path: pids_filenames_csv_path) }
  let(:pids_and_filenames) do
    { "td5xw" =>
        "AUDIT.xml;DC.xml;RELS-EXT.xml;SYMPLECTIC-ATOM.xml;Prinz_2007_systematic-computational-exploration" \
        "-of-the-parameter-space-of-the-multi-compartment-modeTRUNCATED_FILE_NAME.pdf;emoryFIRSTLicense1.odt;" \
        "descMetadata.xml;content.pdf;provenanceMetadata.xml",
      "tdmhk" =>
        "AUDIT.xml;DC.xml;RELS-EXT.xml;SYMPLECTIC-ATOM.xml;Berg_2018_Initiation,_continuation_of_use_and_cessation" \
        "_of_alternative_tobacco_products_among_young_adults-_A_qualitative_study.pdf;emoryFIRSTLicense1.odt;" \
        "descMetadata.xml;content.pdf;provenanceMetadata.xml" }
  end

  context '#pull_pids_and_filenames' do
    it 'returns a hash with PIDs as keys and file list as values' do
      expect(extractor.send(:pull_pids_and_filenames)).to eq(pids_and_filenames)
    end
  end

  context '#assign_values_to_ret_hash' do
    let(:xml_mods) { Nokogiri::XML(File.open(fixture_path + '/xml/descMetadata.xml')) }

    it 'returns the expected values' do
      extractor.instance_variable_set(:@pids_and_filenames, pids_and_filenames)
      extractor.instance_variable_set(:@ret_hash, {})
      extractor.instance_variable_set(:@mods_xml, xml_mods)
      extractor.instance_variable_set(:@pid, 'td5xw')
      extractor.send(:assign_values_to_ret_hash)

      expect(extractor.instance_variable_get(:@ret_hash)).to eq(
        { "title" =>
            "Systematic computational exploration of the parameter space of the multi-compartment model of" \
            " the lobster pyloric pacemaker kernel suggests that the kernel can achieve functional activity" \
            " under various parameter configurations",
          "holding_repository" => "Emory University. Library",
          "emory_content_type" => "Text",
          "content_genre" => "Poster",
          "creator" =>
            "Tomasz G, Smolinski, Emory University|Cristina, Soto-Treviño, New Jersey Institute of Technology|" \
            "Pascale, Rabbah, Rutgers University|Farzan, Nadim, New Jersey Institute of Technology|Astrid A, Prinz, Emory University",
          "creator_last_first" => "Smolinski, Tomasz G|Soto-Treviño, Cristina|Rabbah, Pascale|Nadim, Farzan|Prinz, Astrid A",
          "abstract" => "",
          "date_issued" => "2007-07-12",
          "date_issued_year" => "2007",
          "keyword" => "Current Injection|Model Neuron|Computational Exploration|Axonal Compartment|Pyloric Dilator",
          "parent_title" => nil,
          "publisher" => "",
          "final_published_versions" => "http://dx.doi.org/10.1186/1471-2202-8-S2-P164",
          "issue" => nil,
          "page_range_start" => nil,
          "page_range_end" => nil,
          "volume" => nil,
          "edition" => nil,
          "place_of_production" => nil,
          "issn" => nil,
          "conference_name" => "from Sixteenth Annual Computational Neuroscience Meeting: CNS*2007 Toronto, Canada.",
          "author_notes" => "Email: Tomasz G Smolinski - tomasz.smolinski@emory.edu",
          "rights_statements" => "http://rightsstatements.org/vocab/InC/1.0/",
          "emory_ark" => "ark:/25593/td5xw",
          "research_categories" => "Biology, General",
          "rights_notes" => "© Smolinski et al; licensee BioMed Central Ltd. 2007",
          "publisher_version" => nil,
          "language" => "English",
          "related_datasets" => "",
          "license" => nil,
          "grant_information" => "Support contributed by: Burroughs-Wellcome Fund CASI Award to AAP. NIH MH60605 to FN.",
          "internal_rights_note" =>
            "RightsNote: VB staff-mediated deposit 2.8.2018; fp staff-mediated deposit, switch to Poster 10.8.2018;" \
            " copyrightStatusDeterminationDate: 2018-10-08",
          "file" =>
            "AUDIT.xml;DC.xml;RELS-EXT.xml;SYMPLECTIC-ATOM.xml;Prinz_2007_systematic-computational-exploration-of-the-parameter" \
            "-space-of-the-multi-compartment-modeTRUNCATED_FILE_NAME.pdf;emoryFIRSTLicense1.odt;descMetadata.xml;content.pdf;" \
            "provenanceMetadata.xml",
          "pid" => "td5xw" }
      )
    end
  end
end
