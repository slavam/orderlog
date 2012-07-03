# coding: utf-8
class PriceType < ActiveRecord::Base
#  attr_accessible :name
  has_many :assets
end