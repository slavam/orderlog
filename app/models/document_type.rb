class DocumentType < ActiveRecord::Base
  attr_accessible :name, :description
  has_many :states
end