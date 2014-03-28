plugin_test_dir = File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'rails'
require 'active_record'
require "rails/test_help"

require 'logger'
ActiveRecord::Base.logger = Logger.new(plugin_test_dir + "/debug.log")

require 'yaml'
require 'erb'
ActiveRecord::Base.configurations = YAML::load(ERB.new(IO.read(plugin_test_dir + "/db/database.yml")).result)
ActiveRecord::Base.establish_connection(ENV["DB"] ||= "sqlite3mem")
ActiveRecord::Migration.verbose = false

require 'combustion/database'
Combustion::Database.create_database(ActiveRecord::Base.configurations[ENV["DB"]])
load(File.join(plugin_test_dir, "db", "schema.rb"))

require 'activerecord_any_of'
require 'support/models'

require 'database_cleaner'

ActiveSupport::TestCase.fixture_path = "#{plugin_test_dir}/fixtures"
ActiveSupport::TestCase.use_transactional_fixtures = true
ActiveSupport::TestCase.teardown do
  unless /sqlite/ === ENV['DB']
    Combustion::Database.drop_database(ActiveRecord::Base.configurations[ENV['DB']])
  end
end
