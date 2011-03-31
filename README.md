APPSENT - awesome config management solution
============================================

Description
-----------

In every application (especially big apps, where a lot of people working on it) you need
many config files, where settings for different environments (development, test, and production as minimum),
and you every time use own solution and blabla finish this propaganda...

Usage
-----

Initialize application with config requirements:

	require 'appsent'
	AppSent.init(:path => 'config', :env => ENV['RACK_ENV']) do

	  # Hash-based config:
	  mongo_db_config do
	    host :string, :default => 'localhost', :desc => 'Host to connect to MongoDB'
	    port :integer
	    pool_size :integer
	    timeout :integer
	  end

	  # Array-based config:
	  exception_notification_recipients :array

	  my_simple_config # config without special requirements, stupid but it can do so, why not?
	end

Access to config values performs in a such way:

	AppSent::MONGO_DB_CONFIG['host'] #=>'localhost'
	AppSent::EXCEPTION_NOTIFICATION_RECIPIENTS #=>[...]

TODO: more doc
