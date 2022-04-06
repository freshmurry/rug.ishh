class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.text :comment
      t.integer :star, default: 1
      t.references :rug, foreign_key: true
      t.references :reservation, foreign_key: true
      t.references :guest
      t.references :host
      t.string :type

      t.timestamps
    end
  end
end