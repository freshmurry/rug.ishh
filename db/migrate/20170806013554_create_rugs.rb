class CreateRugs < ActiveRecord::Migration[5.0]
  def change
    create_table :rugs do |t|
      t.string :rug_type
      t.string :address
      t.string :listing_name
      t.text :description
      t.integer :price
      t.boolean :active
      t.float :latitude
      t.float :longitude
      t.boolean :is_freeshipping
      t.string :shiptime
      t.string :size
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end