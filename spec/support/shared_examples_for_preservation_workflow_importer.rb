# frozen_string_literal: true

RSpec.shared_examples 'check_basis_reviewer_for_text' do |type, text|
  it "checks #{type}'s basis_reviewer field for right text" do
    queried_publication = query_service.find_by(id: publication.id)

    expect(queried_publication.preservation_workflows.find { |w| w.workflow_type == type }.workflow_rights_basis_reviewer).to eq text
  end
end
