require 'acts_as_wizard'

ActiveRecord::Base.class_eval do
  include AmosKing::Acts::Wizard
	include AmosKing::Acts::WizardPage
end

ActionView::Base.class_eval do
	include AmosKing::Acts::WizardHelper
end