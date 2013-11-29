#!/usr/bin/env rake
require 'dotenv/tasks'

task :app => :dotenv do
  require './app'
end

namespace :db do
  desc 'Run DB migrations'
  task :migrate => :app do
   require 'sequel/extensions/migration'

   Sequel::Migrator.apply(Brisk::App.database, 'db/migrations')
  end

  desc 'Rollback migration'
  task :rollback => :app do
    require 'sequel/extensions/migration'

    database = Brisk::App.database
    version  = (row = database[:schema_info].first) ? row[:version] : nil
    Sequel::Migrator.apply(database, 'db/migrations', version - 1)
  end

  desc 'Drop the database'
  task :drop => :app do
    database = Brisk::App.database

    database.tables.each do |table|
      database.run("DROP TABLE #{table} CASCADE")
    end
  end

  desc 'Dump the database schema'
  task :dump => :app do
    database = Brisk::App.database

    `sequel -d #{database.url} > db/schema.rb`
    `pg_dump --schema-only #{database.url} > db/schema.sql`
  end
end

namespace :assets do
  desc 'Precompile assets'
  task :precompile => [:precompile_app, :precompile_mobile]

  task :precompile_app => :app do
    assets = Brisk::Routes::Base.assets
    target = Pathname(Brisk::App.root) + 'public/assets'

    %w{application.js application.css}.each do |logical_path|
      if asset = assets.find_asset(logical_path)
        filename = target.join(asset.digest_path)
        FileUtils.mkpath(filename.dirname)
        asset.write_to(filename)
      end
    end

    assets.each_logical_path do |logical_path|
      next if File.extname(logical_path) == '.js'
      if asset = assets.find_asset(logical_path)
        filename = target.join(logical_path)
        FileUtils.mkpath(filename.dirname)
        asset.write_to(filename)
      end
    end
  end

  task :precompile_mobile => :app do
    mobile = Brisk::Routes::Base.mobile
    target = Pathname(Brisk::App.root) + 'public/mobile'

    %w{application.js application.css}.each do |logical_path|
      if asset = mobile.find_asset(logical_path)
        filename = target.join(asset.digest_path)
        FileUtils.mkpath(filename.dirname)
        asset.write_to(filename)
      end
    end

    mobile.each_logical_path do |logical_path|
      next if File.extname(logical_path) == '.js'
      if asset = mobile.find_asset(logical_path)
        filename = target.join(logical_path)
        FileUtils.mkpath(filename.dirname)
        asset.write_to(filename)
      end
    end
  end
end

Dir[File.dirname(__FILE__) + "/lib/tasks/*.rb"].sort.each do |path|
  require path
end
