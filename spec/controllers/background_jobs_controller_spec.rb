# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackgroundJobsController, type: :controller, clean: true do
  include ActionDispatch::TestProcess
  include ActiveJob::TestHelper
  include Devise::Test::ControllerHelpers

  let(:admin) { FactoryBot.create(:admin) }
  let(:user) { FactoryBot.create(:user) }
  let(:csv_file) { fixture_file_upload((fixture_path + '/reindex_files.csv'), 'text/csv') }
  let(:csv_file2) do
    fixture_file_upload((fixture_path + '/preservation_workflows.csv'), 'text/csv')
  end

  let(:new_call) { get :new }

  context "when signed in" do
    before do
      Hyrax.index_adapter.wipe!
      sign_in admin
    end

    # Needed since Jobs were still in queue when next test started, throwing errors.
    after do
      clear_enqueued_jobs
    end

    describe "#new" do
      it 'has 200 code for new' do
        new_call
        expect(response.status).to eq(200)
      end
    end

    describe "#create" do
      let(:preservation) do
        post :create, params: { jobs: 'preservation', preservation_csv: csv_file2, format: 'json' }
      end
      let(:reindex) { post :create, params: { jobs: 'reindex', reindex_csv: csv_file, format: 'json' } }
      let(:link_publications) do
        post :create, params: { jobs: 'publications_to_collection', format: 'json' }
      end

      it "successfully starts a preservation workflow background job" do
        expect(preservation).to redirect_to(new_background_job_path)
        expect(PreservationWorkflowImporterJob).to have_been_enqueued
      end

      it "successfully starts a reindex background job" do
        expect(reindex).to redirect_to(new_background_job_path)
        # Needed to call out how many times the job will be enqueued.
        expect(ReindexObjectJob).to have_been_enqueued.twice
      end

      it "avoids starting BatchAddPublicationsToCollectionJob background job when no unlinked Publications" do
        expect(link_publications).to redirect_to(new_background_job_path)
        # Needed to call out how many times the job will be enqueued.
        expect(BatchAddPublicationsToCollectionJob).not_to have_been_enqueued
      end

      context 'when an unlinked Publication exists' do
        let(:publication) { FactoryBot.valkyrie_create(:publication, with_index: true) }

        it "starts a BatchAddPublicationsToCollectionJob background job when unlinked Publication" do
          publication
          expect(link_publications).to redirect_to(new_background_job_path)
          # Needed to call out how many times the job will be enqueued.
          expect(BatchAddPublicationsToCollectionJob).to have_been_enqueued
        end
      end
    end
  end

  context "when not signed in" do
    describe "#new" do
      it 'has 302 found' do
        expect(new_call).to redirect_to(new_user_session_path.split('?').first)
      end
    end
  end
end
