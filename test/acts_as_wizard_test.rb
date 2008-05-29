require 'rubygems'
require 'test/unit'
require 'mocha'
gem 'activerecord'
gem 'actionpack'
require 'activerecord'
require 'action_controller'
require 'action_controller/test_process'
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. init]))

class Stub < ActiveRecord::Base
end

class ActsAsWizardTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def test_requires_options_for_acts_as_wizard
    assert_raise(AmosKing::Acts::Wizard::ErrPages) { Stub.acts_as_wizard }
  end

	def test_requires_acts_as_state_machine
		Stub.expects(:respond_to?).with(:acts_as_state_machine).returns(false)
		assert_raise(AmosKing::Acts::Wizard::ErrRequireAASM) { Stub.acts_as_wizard(:foo) }
	end
end
