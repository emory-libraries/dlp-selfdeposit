# frozen_string_literal: true

module SelfDeposit
  module Forms
    ##
    # SelfDeposits form for +Hyrax::FileSet+s with inheritance from Hyrax::Forms::FileSetForm.
    class FileSetForm < Hyrax::Forms::FileSetForm
      include Hyrax::FormFields(:emory_file_set_metadata)
    end
  end
end
