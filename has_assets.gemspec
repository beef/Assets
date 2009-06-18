# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_assets}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve England"]
  s.date = %q{2009-06-18}
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
     "app/helpers/admin/assets_helper.rb",
     "app/models/asset.rb",
     "app/models/assetings.rb",
     "app/views/admin/assets/_browser.html.erb",
     "app/views/admin/assets/_document.html.erb",
     "app/views/admin/assets/_file_info.html.erb",
     "app/views/admin/assets/_form.html.erb",
     "app/views/admin/assets/_image.html.erb",
     "app/views/admin/assets/_list.html.erb",
     "app/views/admin/assets/_select_thumbnail.html.erb",
     "app/views/admin/assets/_toggle.html.erb",
     "app/views/admin/assets/index.html.erb",
     "app/views/admin/assets/index.js.rjs",
     "app/views/admin/assets/rename_category.js.rjs",
     "app/views/admin/assets/replace_thumbnail.html.erb",
     "app/views/admin/assets/select_thumbnail.js.rjs",
     "app/views/admin/assets/show.html.erb",
     "app/views/admin/assets/show.js.rjs",
     "lib/has_assets.rb",
     "rails/init.rb",
     "test/has_assets_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/stengland/has_assets}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Adds uploadable assets to a model and admin area for files}
  s.test_files = [
    "test/has_assets_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
