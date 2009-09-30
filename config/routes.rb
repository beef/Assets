ActionController::Routing::Routes.draw do |map|
  map.namespace(:admin) do |admin|
    admin.resources :flickrs
    admin.resources :assets, :collection => { :by_content_type => :get, :descriptions => :get, :by_category => :get, :categories => :get, :category => :get }, :member => { :set_lead => :put, :rename_category => :post }
  end
end