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

  def index
    @flickr_result = {}
    if defined?(Flickr) and File.exists?("#{RAILS_ROOT}/config/flickr.yml")
      flickr = Flickr.new("#{RAILS_ROOT}/config/flickr.yml")
      flickr_params = { :per_page => '12', :page => params[:page], :user_id => Settings.flickr_user_id, :sort => 'date-taken-desc', :tag_mode => 'all' }
      flickr_params[:tags] = params[:tags] unless params[:tags].blank?
      @flickr_result = flickr.photos.search(flickr_params)
    end
    render :layout => false
  end
end