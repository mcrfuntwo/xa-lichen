class Account < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :rules
end
