class WareType < ActiveRecord::Base
  has_many :wares
  has_many :assets
end