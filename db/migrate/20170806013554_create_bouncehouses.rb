class CreateBouncehouses < ActiveRecord::Migration[5.0]
  def change
    create_table :bouncehouses do |t|
      t.string :bouncehouse_type
      t.string :location_type
      t.string :address
      t.string :listing_name
      t.text :description
      t.integer :price
      t.integer :tip
      t.boolean :active
      t.float :latitude
      t.float :longitude
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end