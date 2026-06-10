class IntegrityLog < ApplicationRecord
  validates :idfa, presence: true
  validates :ban_status, presence: true
end