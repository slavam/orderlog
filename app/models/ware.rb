class Ware < ActiveRecord::Base
  attr_accessible :asset_id, :service_id, :cost, :unit_id
  has_many :claim_lines
  belongs_to :ware_type
  belongs_to :asset
  belongs_to :service
  belongs_to :unit
end