class Direction < ActiveRecord::Base
  attr_accessible :name
  has_many :claims
  has_many :assets
end