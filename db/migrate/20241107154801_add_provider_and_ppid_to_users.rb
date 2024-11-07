class AddProviderAndPpidToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :ppid, :string
  end
end
