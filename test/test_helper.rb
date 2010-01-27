require 'rubygems'
require 'test/unit'
require 'mocha'
gem 'activerecord'
gem 'actionpack'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. init]))

# setup db
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])
# load schema file
load(File.dirname(__FILE__) + "/schema.rb") if File.exist?(File.dirname(__FILE__) + "/schema.rb")


class MainModel < ActiveRecord::Base
	acts_as_wizard :first_page, :second_page, :not_ar, :last_page
end

class FirstPage < ActiveRecord::Base
	acts_as_wizard_page :main_model
end

class SecondPage < ActiveRecord::Base
	acts_as_wizard_page :main_model
end

class LastPage < ActiveRecord::Base
	acts_as_wizard_page :main_model
end

class NotAr
  attr_accessor :attribute
end

class EmptyModel < ActiveRecord::Base
end