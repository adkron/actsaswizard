# Title::     ActsAsWizard
# Author::    Amos King  (mailto:damos.l.king@gmail.com)
# Copyright:: Copyright (c) 2008 A. King Software Development and Consulting, LC
# License::   Distributed under the MIT licencse


module AmosKing #:nodoc:
	module Acts #:nodoc:
		module Wizard #:nodoc:
			
			# The Exception raised if there are no arguments passed to acts_as_wizard
			class ErrPages < Exception #:nodoc:
				def message
					"ErrPages: At least one pages must be specified"
				end
      end
			
			def self.included(base)        #:nodoc:
        base.extend ActMacro
      end
			
			module ActMacro #:nodoc:
				# Sets up the main wizard model with the correct states ad transitions. 
        def acts_as_wizard(*opts)
          self.extend(ClassMethods)
          raise ErrPages unless opts.size > 0
					acts_as_state_machine :initial => opts[0]

					opts.each do |opt|
						has_one opt, :dependent => :destroy
						state opt, :after => :current_page
					end
					
					event :next do
						opts.each_cons(2) { |pair| transitions :to => pair.last, :from => pair.first }
					end
					
					event :previous do
						opts.each_cons(2) { |pair| transitions :to => pair.first, :from => pair.last }
					end
					
					self.send(:include, AmosKing::Acts::Wizard::InstanceMethods)
        end
      end
			
			module InstanceMethods
				# return the model for the current wizard page
				def current_page
					@current_page ||= find_page(self.current_state)
				end

				# Returns the model of the page class
				# if the state is :favorite_color the class FavoriteColor is returned
				# and can then have methods called on it.  ie: page_class.new 
				def page_class
					state.to_s.classify.constantize
				end

				# Returns the instance of the current page model that
				# belongs to the wizard controller.
				def page
					send(state.to_s)
				end

				# Used to associate a particular page model with the main wizard model
				def page=(value)
					send(state.to_s + '=', value)
				end

				# Returns the current state as a string
				def current_template
					current_state.to_s
				end

				private
				def find_page(state)
					page_class.send("find_by_#{self.class.to_s.underscore}_id",self.id)
				end
			end
			
			module ClassMethods
			end
		end
		
		module WizardHelper
			  # Creates a button to go to the previous page in the wizard.
			  # Also creates a hidden field used to tell the controller which direction to go.
				def previous_wizard_button(main_wizard_model)
					button_to("&#8592; Previous", 
												{:id => main_wizard_model, :action => "update"}, 
												{:method => :put, 
													:onclick => "$('direction').value = 'previous!';"}) +
					hidden_direction_field
				end
				
				# Creates a button to go to the next page in the wizard.
			  # Also creates a hidden field used to tell the controller which direction to go.
				def next_wizard_button
					submit_tag("Next &#8594;") +
					hidden_direction_field
				end
				
				# Generates a hidden field with the default value next!, and is used in conjunction javascript
				# to pass the correct movement in the wizard to the controller.
				def hidden_direction_field
					hidden_field_tag(:direction, "next!", :class => 'direction')
				end
				
				# Renders the proper partial for the current wizard page
				# pages are stored in app/views/wizard_model_name_wizard_pages/_wizard_page_model_name.html.erb
				def render_wizard_partial(main_wizard_model)
					@page = main_wizard_model.page
					render :partial => wizard_page_template(main_wizard_model), 
								:locals => { :page => main_wizard_model.page}
				end
				
				# Returns the path to the partial for the current tempalte
				# pages are stored in app/views/wizard_model_name_wizard_pages/_wizard_page_model_name.html.erb
				def wizard_page_template(main_wizard_model) 
					"#{main_wizard_model.class.to_s.underscore}_wizard_pages/#{main_wizard_model.current_template}" 
				end

				# Creates a text field for the current wizard page form
				def wizard_page_text_field(field, opts = {})
					if value = @page.send(field.to_s)
						opts[:value] = value
					end
					text_field @page.class.to_s.underscore, field, opts
				end
		end
		
		module WizardController
			def self.included(base)        #:nodoc:
        base.extend ActMacro
      end
			
			module ActMacro #:nodoc:
				# adds some convience methods to the controller for the wizard
        def acts_as_wizard_controller
          self.extend(ClassMethods)
					
					helper_method :get_current_wizard_step
					
					self.send(:include, AmosKing::Acts::WizardController::InstanceMethods)
        end
      end
			
			module InstanceMethods
				private
				# Returns the existing wizard page model or a new one if it doesn't exist
				def get_wizard_page(main_wizard_model)
					main_wizard_model.page = (main_wizard_model.page || main_wizard_model.page_class.new)
				end
				
				# Updates the current page to the next/prevous page and returns the model for that page.
				# The returned model will be a new model if one doesn't already exist.
				def update_current_wizard_page(main_wizard_model)
					page = main_wizard_model.page
					if page 
						page.update_attributes(params[main_wizard_model.current_state]) 
					else 
						page = main_wizard_model.page_class.new(params[main_wizard_model.current_state]) 
						main_wizard_model.page = page
					end
					main_wizard_model.send(params[:direction])
					page
				end
				
				# returns the current page
				def get_current_wizard_step(main_wizard_model)
					main_wizard_model.current_state
				end
			end
			
			module ClassMethods
			end
		end
		
		module WizardPage #:nodoc:
			
			def self.included(base)        #:nodoc:
        base.extend ActMacro
      end
			
			module ActMacro #:nodoc:
				# Calls belongs_to with the model passed to it
        def acts_as_wizard_page(main_wizard_model_symbol)
          self.extend(ClassMethods)

					belongs_to main_wizard_model_symbol
					
					self.send(:include, AmosKing::Acts::Wizard::InstanceMethods)
        end
      end
			
			module InstanceMethods
			end
			
			module ClassMethods
			end
		end
		
	end
end