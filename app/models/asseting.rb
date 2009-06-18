class Asseting < ActiveRecord::Base
  belongs_to :asset
  belongs_to :assetable, :polymorphic => true
  
end