module Beef
  module Has
    module Assets
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def has_assets
          has_many :assetings, :as => :assetable, :dependent => :delete_all
          has_many :assets, :through => :assetings, :order => 'assetings.id'
          
          # Override the default asset_ids method
          define_method("asset_ids=") do |new_value|
            ids = (new_value || []).reject { |nid| nid.blank? }
            ids.collect!{ |id| id.to_i}
            logger.debug "ASSETS the same #{ids == self.asset_ids} | IDS #{ids} | #{self.asset_ids}"
            return if ids == self.asset_ids
            self.assets.clear
            ids.each_index do |idx|
              self.assets << Asset.find(ids[idx])
            end
          end
        end
      end
    end
  end  
end