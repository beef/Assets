module AssetsHelper

  def gallery(assets, size = :square)
    if assets.respond_to? :images and assets.images.any?
      images = assets.images
    elsif assets.any?
      images = assets.reject{|a| !a.content_type.starts_with?('image')}
    else
      return
    end
    images_items = images.collect { |asset| content_tag( :li, link_to(image_tag(asset.public_filename(size), :alt => asset.description), asset.public_filename, :title => asset.description, :rel => 'gallery' ) ) }
    content_tag :ul, images_items.join, :class => 'gallery' unless images_items.empty?
  end

  def documents(assets)
    if assets.respond_to? :documents and assets.documents.any?
      documents = assets.documents
    elsif assets.any?
      documents = assets.reject{|a| a.content_type.starts_with?('image')}
    else
      return
    end
    documents_items = documents.collect { |asset| content_tag( :li, link_to("<em>Download <span class=\"filename\">#{asset.filename}</span></em> (#{number_to_human_size(asset.size)})", asset.public_filename, :title => asset.description, :target => '_blank' ) ) }
    content_tag :ul, documents_items.join, :class => 'documents' unless documents_items.empty?
  end
end