ActiveRecord::Schema.define(:version => 1) do
  create_table :main_models, :force => true do |t|
    t.string :state
  end

	create_table :empty_models, :force => true do |t|
    t.string :state
  end

	create_table :first_pages, :force => true do |t|
    t.integer :main_model_id
  end
end