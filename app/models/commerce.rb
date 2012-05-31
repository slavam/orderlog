class Commerce < ActiveRecord::Base
  establish_connection :findep
  self.abstract_class = true
end