# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/specs/shared_specs/factories/administrative_sets'
require 'hyrax/specs/shared_specs/factories/permission_templates'
require 'hyrax/specs/shared_specs/factories/workflows'

RSpec.describe FilesetCleanUpJob, :clean do
  let(:csv_path) { File.join("config/emory/index_file_set_results.csv") }
  let(:csv) { CSV.read(csv_path) }
  let(:user) { FactoryBot.create(:user) }
  let(:admin_set) { FactoryBot.valkyrie_create(:hyrax_admin_set) }
  let(:permission_template) { FactoryBot.create(:permission_template, source_id: admin_set.id) }
  let!(:workflow) { FactoryBot.create(:workflow, allows_access_grant: true, active: true, permission_template_id: permission_template.id) }
  let(:query_service) { Hyrax.query_service }

  before do
    allow(ValkyrieCharacterizationJob).to receive(:perform_later)
  end

  after do
    File.delete(csv_path) if File.exist?(csv_path)
  end

  shared_examples 'file set characterization' do
    it 'queues characterization job and logs to CSV' do
      expect(ValkyrieCharacterizationJob).to have_received(:perform_later).with(file_set.file_ids.first)
      expect(csv).to include([file_set.id.to_s, "Fileset not characterized", "Queued"])
    end
  end

  context 'when no file_set_ids are provided' do
    let!(:file_set1) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set 1'], depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }
    let!(:file_set2) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set 2'], depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }

    before do
      allow(query_service).to receive(:find_all_of_model).with(model: FileSet).and_return([file_set1, file_set2])
      described_class.perform_now
    end

    it 'processes all file sets' do
      expect(query_service).to have_received(:find_all_of_model).with(model: FileSet)
    end

    it_behaves_like 'file set characterization' do
      let(:file_set) { file_set1 }
    end

    it_behaves_like 'file set characterization' do
      let(:file_set) { file_set2 }
    end
  end

  context 'when specific file_set_ids are provided' do
    let!(:file_set1) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set 1'], depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }
    let!(:file_set2) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set 2'], depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }

    before do
      allow(query_service).to receive(:find_by).with(id: file_set1.id).and_return(file_set1)
      allow(query_service).to receive(:find_by).with(id: file_set2.id).and_return(file_set2)
      described_class.perform_now(file_set1.id, file_set2.id)
    end

    it 'processes only the specified file sets' do
      expect(query_service).to have_received(:find_by).with(id: file_set1.id)
      expect(query_service).to have_received(:find_by).with(id: file_set2.id)
      expect(query_service).not_to have_received(:find_all_of_model)
    end

    it_behaves_like 'file set characterization' do
      let(:file_set) { file_set1 }
    end

    it_behaves_like 'file set characterization' do
      let(:file_set) { file_set2 }
    end
  end

  context 'when an array of file_set_ids is provided' do
    let!(:file_set1) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set 1'], depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }
    let!(:file_set2) { FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set 2'], depositor: user.user_key, read_groups: ['public'], edit_users: [user]) }

    before do
      allow(query_service).to receive(:find_many_by_ids).with(ids: [file_set1.id, file_set2.id]).and_return([file_set1, file_set2])
      described_class.perform_now([file_set1.id, file_set2.id])
    end

    it 'processes the specified file sets' do
      expect(query_service).to have_received(:find_many_by_ids).with(ids: [file_set1.id, file_set2.id])
      expect(query_service).not_to have_received(:find_all_of_model)
    end

    it_behaves_like 'file set characterization' do
      let(:file_set) { file_set1 }
    end

    it_behaves_like 'file set characterization' do
      let(:file_set) { file_set2 }
    end
  end
end
