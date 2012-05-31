class Period < Commerce
  has_many :claims
  self.table_name = "FIN.PERIODS"
end