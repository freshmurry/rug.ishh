class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :image, :string
    add_column :users, :phone_number, :string
    add_column :users, :phone_verified, :boolean
    add_column :users, :pin, :string
    add_column :users, :address, :string
    add_column :users, :description, :text
    add_column :users, :access_token, :string
    add_column :users, :stripe_id, :string
    add_column :users, :merchant_id, :string
    add_column :users, :unread, :integer, default: 0
  end
end