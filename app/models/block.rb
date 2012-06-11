class Block < ActiveRecord::Base
  attr_accessible :name
  has_many :asset_groups
end