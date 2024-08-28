class AddDesiredVisibilityToUploadedFiles < ActiveRecord::Migration[6.1]
  def up
    add_column :uploaded_files, :desired_visibility, :string
  end

  def down
    remove_column :uploaded_files, :desired_visibility
  end
end
