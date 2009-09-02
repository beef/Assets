module RedCloth::Formatters::HTML
  def after_transform(text)
    # Asset Links
    text.gsub! /\[asset\(([^\)]+)\)\]/ do |s|
      asset_id, size = $1.split('|')
      asset = Asset.find_by_id(asset_id)
      return if asset.nil?
      html = "<a href=\"#{asset.public_filename}\" class=\"fancybox\" rel=\"group\">"
      if asset.is_image?
        html << "<img src=\"#{asset.public_filename(size)}\" alt=\"#{asset.description}\" />"
      else
        html << asset.description.titleize
      end
      html << '</a>'
    end
    text.chomp! 
  end
end