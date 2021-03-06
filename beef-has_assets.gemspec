# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{beef-has_assets}
  s.version = "0.7.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve England"]
  s.date = %q{2010-09-08}
  s.email = %q{steve@wearebeef.co.uk}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "app/controllers/admin/assets_controller.rb",
     "app/controllers/admin/flickrs_controller.rb",
     "app/helpers/admin/assets_helper.rb",
     "app/helpers/assets_helper.rb",
     "app/models/asset.rb",
     "app/models/asseting.rb",
     "app/views/admin/assets/_browser.html.erb",
     "app/views/admin/assets/_category_contents.html.erb",
     "app/views/admin/assets/_document.html.erb",
     "app/views/admin/assets/_file_info.html.erb",
     "app/views/admin/assets/_form.html.erb",
     "app/views/admin/assets/_image.html.erb",
     "app/views/admin/assets/_list.html.erb",
     "app/views/admin/assets/_toggle.html.erb",
     "app/views/admin/assets/attach.js.rjs",
     "app/views/admin/assets/category.html.erb",
     "app/views/admin/assets/index.html.erb",
     "app/views/admin/assets/index.js.rjs",
     "app/views/admin/assets/rename_category.js.rjs",
     "app/views/admin/assets/show.html.erb",
     "app/views/admin/assets/show.js.rjs",
     "app/views/admin/flickrs/_flickr_latest.html.erb",
     "app/views/admin/flickrs/_photo.html.erb",
     "app/views/admin/flickrs/_selector.html.erb",
     "app/views/admin/flickrs/index.js.rjs",
     "app/views/admin/flickrs/show.html.erb",
     "app/views/admin/flickrs/show.js.rjs",
     "beef-has_assets.gemspec",
     "config/routes.rb",
     "generators/asset_migration/asset_migration_generator.rb",
     "generators/asset_migration/templates/migration.rb",
     "generators/assets_admin_files/asset_admin_files_generator.rb",
     "generators/assets_admin_files/templates/public/flash/swfupload.swf",
     "generators/assets_admin_files/templates/public/images/flickr_logo.jpg",
     "generators/assets_admin_files/templates/public/javascripts/admin/assets.js",
     "generators/assets_admin_files/templates/public/javascripts/swfupload.js",
     "generators/assets_admin_files/templates/public/javascripts/upload_progress.js",
     "lib/has_assets.rb",
     "lib/has_assets/custom_redcloth_tags.rb",
     "lib/has_assets/flash_sesion_cookie_middleware.rb",
     "lib/has_assets/geometry_crop.rb",
     "lib/has_assets/imagescience_crop.rb",
     "lib/has_assets/swfupload.rb",
     "rails/init.rb",
     "test/has_assets_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/beef/assets}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rails Engine. Adds uploadable assets to a model and admin area for files}
  s.test_files = [
    "test/test_helper.rb",
     "test/has_assets_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

