class AssetAdminFilesGenerator < Rails::Generator::Base
  
  def manifest
    record do |m|
      m.directory File.join("public", "javascripts", "admin")
      m.directory File.join("public", "stylesheets", "admin")
      m.directory File.join("public", "flash")
    
    
      ["public/flash/swfupload.swf",
      "public/javascripts/admin/assets.js",
      "public/javascripts/swfupload.js",
      "public/javascripts/upload_progress.js"].each do |file|
         m.file file, file
      end
    end
  end
  
end