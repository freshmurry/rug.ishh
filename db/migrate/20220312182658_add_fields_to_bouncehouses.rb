class AddFieldsToBouncehouses < ActiveRecord::Migration[5.0]
  def change
    add_column :bouncehouses, :size, :string
    add_column :bouncehouses, :shiptime, :string
    add_column :bouncehouses, :is_blower, :boolean
    add_column :bouncehouses, :is_repairkit, :boolean
    add_column :bouncehouses, :is_transportbag, :boolean
    add_column :bouncehouses, :is_instructionalvideo, :boolean
    add_column :bouncehouses, :is_freeshipping, :boolean
  end
end