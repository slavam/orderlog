class Status < ActiveRecord::Base
  attr_accessible :name
  has_many :clime_lines
end