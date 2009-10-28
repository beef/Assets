class Admin::AssetsController < Admin::BaseController
  unloadable
  
  protect_from_forgery :except => [:destroy, :rename_category]

  # GET /assets
  # GET /assets.xml
  def index
    @asset_types = Asset.grouped_by_category
    @grouping = 'by_category'

    respond_to do |format|
      format.html { render :action => 'index'}
      format.xml  { @asset_types.to_xml }
      format.js { render :action => 'index'}
    end
  end
  
  alias :by_category :index
  
  def by_content_type
    @asset_types = Asset.grouped_by_content_type
    @grouping = 'by_content_type'

    respond_to do |format|
      format.html { render :action => 'index'}
      format.xml  { @asset_types.to_xml }
      format.js { render :action => 'index'}
    end
  end
  
  def by_description
    @asset_types = Asset.grouped_by_description
    @grouping = 'by_description'

    respond_to do |format|
      format.html { render :action => 'index'}
      format.xml  { @asset_types.to_xml }
      format.js { render :action => 'index'}
    end
  end

  def category
    @assets = Asset.all(:conditions => ["category = ?",params[:category]])

    respond_to do |format|
      format.html { render :layout => false}
      format.xml  { @assets.to_xml }
      format.js { render :layout => false}
    end
  end

  def content_type
    @assets = Asset.not_thumbnails.all(:conditions => ["content_type = ?",params[:category]])

    respond_to do |format|
      format.html { render :layout => false, :action => 'category'}
      format.xml  { @assets.to_xml }
      format.js { render :layout => false, :action => 'category'}
    end
  end
  
  def descriptions
    @descriptions = Asset.not_thumbnails.find(:all, :select => 'description', :group => 'description', :order => 'description', :conditions => 'description IS NOT NULL')
    
    respond_to do |format|
      format.json { render :json => @descriptions.collect{ |a| a.description }}
    end
  end
  
  def categories
    @categories = Asset.not_thumbnails.find(:all, :select => 'category', :group => 'category', :order => 'category', :conditions => 'category IS NOT NULL')
    
    respond_to do |format|
      format.json { render :json => @categories.collect{ |a| a.category }}
    end
  end

  # GET /assets/1
  # GET /assets/1.xml
  def show
    @asset = Asset.find(params[:id])

    respond_to do |format|
      format.js
      format.xml  { render :xml => @asset }
    end
  end

  # POST /assets
  # POST /assets.xml
  def create
    @asset = Asset.new(params[:asset])

    respond_to do |format|
      if @asset.save
        flash[:notice] = 'Asset was successfully created.'
        format.html { redirect_to(admin_assets_url) }
        format.xml  { render :xml => @asset, :status => :created, :location => admin_asset_url(@asset) }
        format.js  { render :json => @asset, :status => 200, :location => admin_asset_url(@asset) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset.errors, :status => :unprocessable_entity }
        format.js  { render :json => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /assets/1
  # PUT /assets/1.xml
  def update
    @asset = Asset.find(params[:id])

    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        format.html do
          flash[:notice] = 'Asset was successfully updated.'
          redirect_to(admin_assets_url)
        end
        format.xml  { head :ok }
        format.js  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @asset.errors, :status => :unprocessable_entity }
        format.js  { render :json => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def select_thumbnail
    @asset = Asset.find(params[:id])
    respond_to do |wants|
      wants.html { render :action => 'replace_thumbnail' }
      wants.js
    end
  end
  
  def replace_thumbnail
    @asset = Asset.find(params[:id])
    @asset.create_or_update_thumbnail(params[:asset][:uploaded_data],:square,Asset.attachment_options[:thumbnails][:square])
    respond_to do |format|
      format.html do
        flash[:notice] = 'Thumbnail was successfully updated.'
        redirect_to admin_assets_path
      end
      format.js { render :json => @asset, :status => 200 }
    end
    
  rescue Technoweenie::AttachmentFu::ThumbnailError => m
    
    respond_to do |format|
      format.html { flash[:error] = m }
      format.js { render :json => [m] }
    end
  end
  
  def rename_category
    respond_to do |format|
      format.js do
        @asset = Asset.find(params[:id])
        @old_category_name = @asset.category
        @new_category_name = params[:name]
        Asset.update_all({:category => @new_category_name}, {:category => @old_category_name}) unless @new_category_name.blank?
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @asset = Asset.find(params[:id])
    @asset.destroy

    respond_to do |format|
      format.html { redirect_to(admin_assets_url) }
      format.js { render :nothing => true }
      format.xml  { head :ok }
    end
  end
end
