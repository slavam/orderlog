class Business < Commerce
  has_many :claim_lines
  self.table_name = "FIN.BUDGET_BUSINESS"
end