class AssetMigrationGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.migration_template "migration.rb",
                           'db/migrate',
                           :migration_file_name => "create_assets"
    end
  end
  
end
