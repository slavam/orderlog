# coding: utf-8
class AssetGroup < ActiveRecord::Base
  attr_accessible :name, :block_id
  belongs_to :block
  has_many :assets
  def self.get_full_groups
    groups = []
    groups[0] = AssetGroup.new
    groups[0].id = 0
    groups[0].name = 'Вне группы'
    AssetGroup.all.each {|g| groups << g}
    return groups
  end
end