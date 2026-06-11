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

    new_user = user.new_record?
    old_status = user.ban_status
    vpn_result = { vpn: nil, proxy: nil, tor: nil }

    new_status = run_checks(vpn_result)

    user.ban_status = new_status
    user.save!

    create_log_if_needed(new_user, old_status, new_status, vpn_result)

    new_status
  end

  private

  def run_checks(vpn_result)
    return BANNED unless country_whitelisted?
    return BANNED if @rooted_device == true

    result = VpnApiService.new(ip: @ip).call
    vpn_result.merge!(result)

    return BANNED if result[:vpn] == true
    return BANNED if result[:proxy] == true
    return BANNED if result[:tor] == true

    NOT_BANNED
  end

  def country_whitelisted?
    return false if @country.blank?

    $redis.sismember("country_whitelist", @country)
  end

  def create_log_if_needed(new_user, old_status, new_status, vpn_result)
    return unless new_user || old_status != new_status

    IntegrityLoggerService.new(
      idfa: @idfa,
      ban_status: new_status,
      ip: @ip,
      rooted_device: @rooted_device,
      country: @country,
      proxy: vpn_result[:proxy],
      vpn: vpn_result[:vpn]
    ).call
  end
end
