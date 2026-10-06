require_relative "config/environment"

Dir[File.join(APP_ROOT, "lib", "tasks", "**", "*.rake")].sort.each { |f| load f }

namespace :db do
  desc "Crée (ou recrée) la base à partir de db/schema.rb"
  task :setup do
    config = ActiveRecord::Base.connection_db_config
    name   = config.database

    ActiveRecord::Base.establish_connection(config.configuration_hash.merge(database: "postgres"))
    ActiveRecord::Base.connection.drop_database(name) rescue nil
    ActiveRecord::Base.connection.create_database(name)
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Migration.verbose = false
    
    load File.join(APP_ROOT, "db", "schema.rb")
    puts "Base #{name} prête."
  end
end

task default: :spec

desc "Lance la suite de tests"
task :spec do
  sh "bundle exec rspec"
end
