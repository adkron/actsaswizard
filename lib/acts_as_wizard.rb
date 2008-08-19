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
					class_inheritable_reader :pages
					write_inheritable_attribute :pages, opts
					
					opts.each { |opt| has_one opt if respond_to? :has_one }
           
					self.send(:include, AmosKing::Acts::Wizard::InstanceMethods)
        end
      end
			
			module InstanceMethods
				# returns a symbol for the current wizard page
				def get_current_wizard_step
					pages[self.state || 0]
				end
				
				def next!
				  self.state ||= 0
					self.state += 1 unless self.state + 1 >= pages.size
				end
				
				def previous!
				  self.state ||= 0
					self.state -= 1 unless self.state <= 0
				end

				# Returns the class of the current page
				# if the state is :favorite_color the class FavoriteColor is returned
				# and can then have methods called on it.  ie: page_class.new 
				def page_class
					current_template.classify.constantize
				end

				# Returns the instance of the current page model that
				# belongs to the wizard controller.
				def page
					send(current_template)
				end

				# Used to associate a particular page model with the main wizard model
				def page=(value)
					send("#{current_template}=", value)
				end

				# Returns the current state as a string
				def current_template
					get_current_wizard_step.to_s
				end
				
				# Returns the existing wizard page model or a new one if it doesn't exist
				def get_wizard_page
					self.page ||= self.page_class.new
				end
				
				# Updates the current page to the next/prevous page and returns the model for that page.
				# The returned model will be a new model if one doesn't already exist.
				def switch_wizard_page(direction)
					send(direction)
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
										 :onclick => "document.getElementById('direction').value = 'previous!';"}) +
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
					render :partial => wizard_page_template(main_wizard_model)
				end
				
				# Returns the path to the partial for the current tempalte
				# pages are stored in app/views/wizard_model_name_wizard_pages/_wizard_page_model_name.html.erb
				def wizard_page_template(main_wizard_model) 
					"#{main_wizard_model.class.to_s.underscore}_wizard_pages/#{main_wizard_model.current_template}" 
				end

				# Creates a text field for the current wizard page form
				def wizard_page_text_field(field, opts = {})
					opts[:value] = @page.send(field.to_s)
					text_field @page.class.to_s.underscore, field, opts
				end
				
				# Creates a text field for the current wizard page form
				def wizard_page_text_area(field, opts = {})
					opts[:value] = @page.send(field.to_s)
					text_area @page.class.to_s.underscore, field, opts
				end
				
				# Creates a select field for the current wizard page form
				def wizard_page_select(field, options, opts = {})
				  opts[:selected] = @page.send(field.to_s)
					select @page.class.to_s.underscore, field, options, opts
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

					belongs_to main_wizard_model_symbol if respond_to? :belongs_to
					
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