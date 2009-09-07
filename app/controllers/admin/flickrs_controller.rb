class Admin::FlickrsController < Admin::BaseController
  def create
    flickr = Flickr.new("#{RAILS_ROOT}/config/flickr.yml")
    redirect_to flickr.auth.url(:write)
  end
  def show
    respond_to do |format|
      format.html do
        flickr = Flickr.new("#{RAILS_ROOT}/config/flickr.yml")
        flickr.auth.cache_token        
      end
      format.js
    end
  end

end