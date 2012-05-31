# coding: utf-8
class AssetType < ActiveRecord::Base
#  attr_accessible :name
  has_many :assets
end