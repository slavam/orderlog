class Unit < ActiveRecord::Base
#  attr_accessible :name, :part_number
  has_many :wares
#  has_many :services
end