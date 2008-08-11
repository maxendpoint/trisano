# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Uncomment the following line for running in Tomcat
  # TODO: Find permanent fix
  #config.logger = Logger.new(STDOUT)

  # Uncomment the following line if you want to read the log file in Eclipse
  # config.active_record.colorize_logging = false

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_nedss_session',
    :secret      => 'dec289bfea4950e50e37af2854f59c2a7a96c0a8d24ef218517b08a5790a272ae2b2ee0c2fe5aa18217a599b20b322c5596fd3983a42240aef4ce71a37102d41'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # For datetime validation plugin to switch to U.S. format (month/day/year)
  # http://svn.viney.net.nz/things/rails/plugins/validates_date_time/README 
  config.after_initialize do
    ValidatesDateTime.us_date_format = true
    require "active_record/errors.rb"
    require "soundex/Soundex.rb"
    require "mmwr/mmwr.rb"
    require "blankable.rb"
    require "extend_better_nested_set.rb"
    require 'export/csv'
  end

end

PG_LOCALE = ENV['PG_LOCALE'] ||= 'en_US' 

if RAILS_ENV == "development" || RAILS_ENV == "test"
  NEDSS_UID = ENV['NEDSS_UID']
else
  NEDSS_UID = nil
end