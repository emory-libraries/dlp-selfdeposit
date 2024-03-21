# frozen_string_literal: true

class PreservationWorkflow < Valkyrie::Resource
  include Hyrax::Schema(:preservation_workflow_metadata)

  def preservation_terms
    attributes_map = { 'workflow_type' => workflow_type,
                       'workflow_notes' => workflow_notes,
                       'workflow_rights_basis' => workflow_rights_basis,
                       'workflow_rights_basis_note' => workflow_rights_basis_note,
                       'workflow_rights_basis_date' => workflow_rights_basis_date,
                       'workflow_rights_basis_reviewer' => workflow_rights_basis_reviewer,
                       'workflow_rights_basis_uri' => workflow_rights_basis_uri }
    attributes_map.to_json
  end
end
