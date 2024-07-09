class AddFilesetUseAndNameToUploadedFiles < ActiveRecord::Migration[6.1]
  def change
    add_column :uploaded_files, :fileset_name, :string
    add_column :uploaded_files, :fileset_use, :string
  end
end
