module Admin::AssetsHelper

  def asset_list(content_node)
    list = render( :partial => '/admin/assets/list', :locals => { :content_node => content_node, :assets => content_node.assets.images, :title => 'Gallery' } )
    list << render( :partial => '/admin/assets/list', :locals => { :content_node => content_node, :assets => content_node.assets.documents, :title => 'Downloads' } )
    content_tag :div, list, :id => 'attach-asset-list'
  end

  def asset_browser(for_content = false)
    render :partial => '/admin/assets/browser',
           :locals => { :asset_types => Asset.grouped_by_category,
                        :for_content => for_content,
                        :ajaxify        => true }
  end

  def asset_upload_form
    render :partial => '/admin/assets/form'
  end

  def toggle_grouping_links
    render :partial => 'admin/assets/toggle'
  end

  def admin_assets_path_with_session_information
    logger.debug "Nom Nom #{cookies.to_hash.compact.inspect}"
    session_key = ActionController::Base.session_options[:key]
    params = {request_forgery_protection_token => form_authenticity_token, :cookies => cookies.reject{ |k,v| k.nil? } }
    admin_assets_path(params)
  end

  def replace_thumbnail_admin_asset_path_with_session_information(asset)
    session_key = ActionController::Base.session_options[:key]
    replace_thumbnail_admin_asset_path(asset, session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
  end


  def lastest_flickr
    return unless defined?(Flickr) and File.exists?("#{RAILS_ROOT}/config/flickr.yml") and !Settings.flickr_user_id.blank?
    flickr = Flickr.new("#{RAILS_ROOT}/config/flickr.yml")
    flickr_params = { :per_page => '5', :page => params[:page], :user_id => Settings.flickr_user_id, :sort => 'date-taken-desc', :tag_mode => 'all' }
    flickr_params[:tags] = params[:tags] unless params[:tags].blank?
    flickr_result = flickr.photos.search(flickr_params)
    render :partial => 'admin/shared/flickr_latest.html.erb', :locals => { :flickr_images => flickr_result }
  rescue RuntimeError => e
    logger.warn "Flickr error: #{e}"
    return
  end


  def flickr_select
    return unless defined?(Flickr) and File.exists?("#{RAILS_ROOT}/config/flickr.yml") and !Settings.flickr_user_id.blank?
    render :partial => 'admin/flickrs/selector'
  end

  def flickr_default_size
    defined?(Beef::Has::Assets::FLICKR_DEFAULT_SIZE) ?  Beef::Has::Assets::FLICKR_DEFAULT_SIZE : :medium
  end
end
