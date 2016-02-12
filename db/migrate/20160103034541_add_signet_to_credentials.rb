class AddSignetToCredentials < ActiveRecord::Migration
  def change
    add_column :credentials, :email, :string
    add_column :credentials, :signet, :text
    add_index :credentials, :email, unique: true
  end
end
