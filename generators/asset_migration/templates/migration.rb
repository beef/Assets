class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :filename, :category, :description,  :content_type
      t.integer :size, :height , :width
      t.references :parent, :assetable
      t.string :assetable_type, :limit => 20
      t.string :thumbnail

      t.timestamps
    end
    
    add_index :assets, :content_type
    
    create_table :assetings do |t|
      t.references :asset, :assetable
      t.string :assetable_type, :limit => 20
      t.integer :position, :default => 1, :null => false 
      t.timestamps
    end
    
    add_index :assetings, :asset_id
    add_index :assetings, [:assetable_id, :assetable_type]
  end

  def self.down
    drop_table :assetings
    drop_table :assets
  end
end