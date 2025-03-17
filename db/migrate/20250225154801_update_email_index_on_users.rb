class UpdateEmailIndexOnUsers < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, :email
    add_index :users, :email, unique: false
  end
end
