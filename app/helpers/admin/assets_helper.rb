module Admin::AssetsHelper
  
  def asset_list(content_node)
    unless content_node.assets.empty?
      list = render( :partial => '/admin/assets/list', :locals => { :content_node => content_node } )
    end
    content_tag :div, list, :id => 'attach-asset-list'
  end
  
  def asset_browser(for_content = false)
    render :partial => '/admin/assets/browser', 
           :locals => { :asset_types => Asset.grouped_by_category,
                        :for_content => for_content }
  end
  
  def asset_upload_form
    render :partial => '/admin/assets/form'
  end
  
  def toggle_grouping_links
    render :partial => 'admin/assets/toggle'
  end
  
  def admin_assets_path_with_session_information
    session_key = ActionController::Base.session_options[:key]
    params = {request_forgery_protection_token => form_authenticity_token, :cookies => cookies}
    admin_assets_path(params)
  end
  
  def replace_thumbnail_admin_asset_path_with_session_information(asset)
    session_key = ActionController::Base.session_options[:key]
    replace_thumbnail_admin_asset_path(asset, session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
  end

end
