# coding: utf-8
class BudgetItem < Commerce
  has_many :claim_lines
  has_many :assets
  has_many :services
#  belongs_to :division_parent, :class_name => 'DivisionParent', :foreign_key => 'parent_id'
  self.table_name = "FIN.BUDGET_DIRECTORY"

  def self.find_budget_items
    budget_items = []
    budget_items[0] = BudgetItem.new
    budget_items[0].id = 0
    budget_items[0].name = 'Вне бюджета' 
    budget_items[0].code = ''
    budget_items[0][:isleaf] = 0
    budget_items[0].parent_id = 0
    query = "
      SELECT t.id as id,
              LPAD(' ', (LEVEL*2 - 1) * 2) || t.name as name,
              CONNECT_BY_ISLEAF AS ISLEAF,
              t.parent_id,
              t.code
      FROM FIN.budget_directory t
      CONNECT BY NOCYCLE  PRIOR t.ID = t.PARENT_ID
      start with t.PARENT_ID in (488,153)
      ORDER SIBLINGS BY t.name    
    "
    BudgetItem.find_by_sql(query).each {|bi| budget_items << bi}
    return budget_items
  end
  
end