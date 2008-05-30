require File.expand_path(File.join(File.dirname(__FILE__), *%w[lib acts_as_wizard]))

ActiveRecord::Base.class_eval do
  include AmosKing::Acts::Wizard
	include AmosKing::Acts::WizardPage
end

ActionView::Base.class_eval do
	include AmosKing::Acts::WizardHelper
end