# frozen_string_literal: true
# [Hyrax-override-v5.2.0]
# Adds tests for fixity_check preservation_event
require 'rails_helper'

RSpec.describe FixityCheckJob, :clean do
  let(:user) { FactoryBot.create(:user) }
  let(:file_set) do
    FactoryBot.valkyrie_create(:hyrax_file_set, :with_files, title: ['Test File Set'], depositor: user.user_key, read_groups: ['public'], edit_users: [user])
  end
  let(:file_id) { file_set.original_file.id.to_s }
  let(:log_record) { described_class.perform_now(file_set_id: file_set.id, initiating_user: user) }

  describe "called with perform_now" do
    context 'fixity check the content' do
      let(:uri) { file_set.original_file.file_identifier.to_s.gsub('fedora', 'http') }

      it 'passes' do
        expect(log_record).to be_passed
      end
      it "returns a ChecksumAuditLog" do
        expect(log_record).to be_kind_of ChecksumAuditLog
        expect(log_record.checked_uri).to eq uri
        expect(log_record.file_id).to eq file_id
        expect(log_record.file_set_id).to eq file_set.id
      end
    end

    describe 'creates fixity_check preservation_events' do
      it 'creates a successful fixity_check preservation_event' do
        log_record
        reloaded_fs = Hyrax.query_service.find_by(id: file_set.id)
        expect(reloaded_fs.preservation_events.pluck(:event_details)).to match_array ["Fixity intact for file: image.png: sha1: "]
      end
    end
  end
end
