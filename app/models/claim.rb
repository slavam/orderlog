class Claim < ActiveRecord::Base
  attr_accessible :direction_id, :claim_number, :division_id, :period_id
  has_many :claim_lines, :dependent => :destroy
  has_many :claim_histories
  belongs_to :branch_of_bank, :class_name => 'BranchOfBank', :foreign_key => 'division_id'
  belongs_to :period, :class_name => 'Period', :foreign_key => 'period_id'
  belongs_to :direction
  belongs_to :state
end