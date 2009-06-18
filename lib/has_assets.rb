module Beef
  module Has
    module Assets
      module ClassMethods
        def has_assets
          send :include, InstanceMethods

          has_many :assetings, :as => :assetable, :order => 'assetable.id', :dependent => :delete_all
          has_many :assets, :through => :assetings do
            # Returns all assets grouped by content type
            def grouped_by_content_type
              not_thumbnails.all( :order => 'filename' ).group_by(&:content_type).sort
            end
          end

        end
      end

      module InstanceMethods

        # Override the generated method to allow for ordering
        def asset_ids=(ids)
          # Sure ids are number
          ids.collect!{ |id| id.to_i}
          logger.debug "ASSETS the same #{ids == self.asset_ids} | IDS #{ids} | #{self.asset_ids}"
          return if ids == self.asset_ids
          self.assets.clear
          ids.each_index do |idx|
            self.assets << Asset.find(ids[idx])
          end
        end

      end

      def self.included(base)
        base.extend ClassMethods
      end
    end
  end  
end