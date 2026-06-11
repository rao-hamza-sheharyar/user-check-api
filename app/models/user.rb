class User < ApplicationRecord
  BAN_STATUSES = %w[not_banned banned].freeze

  validates :idfa, presence: true, uniqueness: true
  validates :ban_status, presence: true, inclusion: { in: BAN_STATUSES }

  def banned?
    ban_status == "banned"
  end
end
