class ClaimLine < ActiveRecord::Base
  attr_accessible :count, :for_whom, :description, :budget_item_id, :asset_id, :cost, :business_id, :status_id
  belongs_to :claim
  belongs_to :business
  belongs_to :worker, :class_name => 'Worker', :foreign_key => 'for_whom'
  belongs_to :budget_item
  belongs_to :asset
  belongs_to :status
end