module AssetsHelper

  def gallery(assets, size = :square)
    images_items = assets.images.collect { |asset| content_tag( :li, link_to(image_tag(asset.public_filename(size), :alt => asset.description), asset.public_filename, :title => asset.description, :rel => 'gallery' ) ) }
    content_tag :ul, images_items.join, :class => 'gallery' unless images_items.empty?
  end
  
  def documents(assets)
    documents_items = assets.documents.collect { |asset| content_tag( :li, link_to("Download #{asset.filename} (#{number_to_human_size(asset.size)})", asset.public_filename, :title => asset.description ) ) }
    content_tag :ul, documents_items.join, :class => 'documents' unless documents_items.empty?
  end
end