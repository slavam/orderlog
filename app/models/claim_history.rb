class ClaimHistory < ActiveRecord::Base
#  attr_accessible :asset_id, :service_id
  belongs_to :claim
  belongs_to :state
end