class Asset < ActiveRecord::Base
  attr_accessible :name, :part_number, :budget_item_id, :direction_id, :asset_group_id, :info, :cost, :ware_type_id, :unit_id
  has_many :claim_lines
  belongs_to :unit
  belongs_to :budget_item
  belongs_to :direction
  belongs_to :asset_group
  belongs_to :ware_type
end