class State < ActiveRecord::Base
  attr_accessible :document_type_id, :state_name_id
  belongs_to :state_name
  belongs_to :document_type
  has_many :claims
  has_many :claim_histories
end