class ClaimLine < ActiveRecord::Base
  attr_accessible :ware_id, :count, :for_whom, :description, :budget_item_id, :asset_id
  belongs_to :claim
  belongs_to :ware
  belongs_to :worker, :class_name => 'Worker', :foreign_key => 'for_whom'
  belongs_to :budget_item
  belongs_to :asset
end