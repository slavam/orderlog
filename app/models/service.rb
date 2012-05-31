class Service < ActiveRecord::Base
  attr_accessible :name, :part_number, :budget_item_id
  belongs_to :unit
  belongs_to :budget_item
end