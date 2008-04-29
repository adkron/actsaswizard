# ActsAsWizard
module AmosKing #:nodoc:
	module Acts #:nodoc:
		module Wizard #:nodoc:
			class ErrPages < Exception #:nodoc:
				def message
					"ErrPages: At least two pages must be specified"
				end
      end
			
			def self.included(base)        #:nodoc:
        base.extend ActMacro
      end
			
			module ActMacro #:nodoc:
        def acts_as_wizard(*opts)
          self.extend(ClassMethods)
          raise ErrPages unless opts.size > 1
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
				def current_page
					@current_page ||= find_page(self.current_state)
				end

				def page_class
					state.to_s.classify.constantize
				end

				def page
					send(state.to_s)
				end

				def page=(value)
					send(state.to_s + '=', value)
				end

				def current_template
					current_state.to_s
				end

				private
				def find_page(state)
					page_class.find_by_agency_id(self.id)
				end
			end
			
			module ClassMethods
			end
		end
		
		module WizardHelper
				def previous_wizard_button(main_wizard_model)
					button_to("&#8592; Previous", 
												{:id => main_wizard_model, :action => "update"}, 
												{:method => :put, 
													:onclick => "$('direction').value = 'previous!';"}) +
					hidden_direction_field
				end

				def next_wizard_button
					submit_tag("Next &#8594;") +
					hidden_direction_field
				end
				
				def hidden_direction_field
					hidden_field_tag(:direction, "next!", :class => 'direction')
				end
				
				def render_wizard_partial(main_wizard_model)
					render :partial => wizard_page_template(main_wizard_model), 
								:locals => { :page => main_wizard_model.page}
				end
				
				def wizard_page_template(main_wizard_model) 
					"#{main_wizard_model.class.to_s.underscore}_wizard_pages/#{main_wizard_model.current_template}" 
				end

				def wizard_page_text_field(page, field)
					text_field page.class.to_s.underscore, field, :value => page.send(field.to_s)
				end
		end
		
		module WizardController
			def self.included(base)        #:nodoc:
        base.extend ActMacro
      end
			
			module ActMacro #:nodoc:
        def acts_as_wizard_controller
          self.extend(ClassMethods)
					
					helper_method :get_current_wizard_step
					
					self.send(:include, AmosKing::Acts::WizardController::InstanceMethods)
        end
      end
			
			module InstanceMethods
				private
				def get_wizard_page(main_wizard_model)
					main_wizard_model.page || main_wizard_model.page_class.new
				end
				
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