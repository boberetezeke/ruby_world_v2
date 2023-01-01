class GitbaseRecord < ApplicationRecord
  self.abstract_class = true

  include GitBaseRails
end