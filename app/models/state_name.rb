class StateName < ActiveRecord::Base
  attr_accessible :name
  has_many :states
end