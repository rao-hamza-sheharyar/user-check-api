class UserCheckStatusService
  BANNED = "banned"
  NOT_BANNED = "not_banned"

  def initialize(idfa:, rooted_device:, ip:, country:)
    @idfa = idfa
    @rooted_device = rooted_device
    @ip = ip
    @country = country
  end

  def call
    user = User.find_or_initialize_by(idfa: @idfa)

    return BANNED if user.persisted? && user.banned?

    ban_status = run_checks

    old_status = user.ban_status
    user.ban_status = ban_status
    user.save!

    create_integrity_log_if_needed(user, old_status)

    ban_status
  end

  private

  def run_checks
    return BANNED unless country_whitelisted?
    return BANNED if @rooted_device == true

    NOT_BANNED
  end

  def country_whitelisted?
    $redis.sismember("country_whitelist", @country)
  end

  def create_integrity_log_if_needed(user, old_status)
    return if user.persisted? && old_status == user.ban_status

    IntegrityLog.create!(
      idfa: @idfa,
      ban_status: user.ban_status,
      ip: @ip,
      rooted_device: @rooted_device,
      country: @country,
      proxy: nil,
      vpn: nil
    )
  end
end