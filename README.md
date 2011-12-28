APPSENT - awesome config management solution [![Build Status](http://travis-ci.org/kucaahbe/appsent.png)](http://travis-ci.org/kucaahbe/appsent)
================================================================================================================================================

## Description

In every application (especially big apps, where a lot of people working on it) you need
to have many config files, where settings for different environments (development, test, and production as minimum),
and without some settings there application will fail, and sometime it takes long time to find  where was mistake.
This gem provides easy way to handle loading different config files, validations for necessary config values, in a such way:
your application will not start until you fill all needed settings, and when you done you will have access to every your in a convenient way.

## Usage

Initialize application with config requirements:

	require 'appsent'
	AppSent.init(:path => 'config', :env => ENV['RACK_ENV']) do

	  # Hash-based config:
	  mongo_db_config do
	    host      String, 'Host to connect to MongoDB' => 'localhost'
	    port      Fixnum, 'Port to connect to MongoDB'
	    pool_size Fixnum
	    timeout   Fixnum
	  end

	  exception_notification_recipients Array

	end

Access to config values performs in a such way:

	AppSent::MONGO_DB_CONFIG['host'] #=>'localhost'
	AppSent::EXCEPTION_NOTIFICATION_RECIPIENTS #=>[...]

## Contributin'

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* run rake command to verify you haven't broke anything.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send a pull request. Bonus points for topic branches.


TODO: more doc
