require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. test_helper]))

class ActsAsWizardTest < Test::Unit::TestCase
	def setup
		@main_model = MainModel.new
		@main_model.save
	end
	
	def test_nonactive_record_model
	  	@main_model.next
	  	@main_model.next
  		assert_equal(:not_ar, @main_model.get_current_wizard_step)
  end
	
	def test_err_pages_message
		assert_equal("ErrPages: At least one pages must be specified",AmosKing::Acts::Wizard::ErrPages.new.message)
	end
	
  def test_requires_options_for_acts_as_wizard
    assert_raise(AmosKing::Acts::Wizard::ErrPages) { EmptyModel.acts_as_wizard }
  end
	
	def test_no_errors
		EmptyModel.acts_as_wizard(:foo)
	end
	
	def test_get_wizard_page_returns_a_new_first_page_when_there_is_no_first_page
		@page = @main_model.get_wizard_page
		assert_equal(FirstPage, @page.class)
	end
	
	def test_get_wizard_page_returns_the_first_page_when_there_is_a_first_page
		@main_model.page = FirstPage.new
		@main_model.page.save
		@expected_page = @main_model.page
		@page = @main_model.get_wizard_page
		assert_equal(@expected_page, @page)
	end
	
	def test_get_current_wizard_step_returns_first_page_on_new_model
		assert_equal(:first_page, @main_model.get_current_wizard_step)
	end
	
	def test_current_template_returns_current_wizard_step_as_a_string
		assert_equal("first_page", @main_model.current_template)
	end
	
	def test_get_current_wizard_step_returns_second_page_after_next_called
		@main_model.next
		assert_equal(:second_page, @main_model.get_current_wizard_step)
	end
	
	def test_get_current_wizard_step_returns_first_page_after_next_called_and_then_previous_called
		@main_model.next
		@main_model.previous
		assert_equal(:first_page, @main_model.get_current_wizard_step)
	end
	
	def test_get_current_wizard_step_returns_first_page_if_previous_called_on_first_page
		@main_model.previous
		assert_equal(:first_page, @main_model.get_current_wizard_step)
	end
	
	def test_get_current_wizard_step_returns_last_page_after_when_next_called_on_last_page
		@main_model.pages.size.times {@main_model.next}
	  @main_model.next
		assert_equal(:last_page, @main_model.get_current_wizard_step)
	end
	
	def test_page_class_returns_the_class_of_the_first_page_on_a_new_wizard
		assert_equal(FirstPage, @main_model.page_class)
	end
	
	def test_page_class_returns_the_correct_class_after_chaning_pages
		@main_model.next
		assert_equal(SecondPage, @main_model.page_class)
	end
	
	def test_pages_is_assigned_correctly
		assert_equal [:first_page, :second_page, :not_ar, :last_page], @main_model.pages
	end
	
	def test_next_can_be_chained
	  @main_model.next.next
		assert_equal(NotAr, @main_model.page_class)
  end
  
  def test_previous_can_be_chained
    @main_model.next.previous.next
  	assert_equal(SecondPage, @main_model.page_class)
  end
	
end
