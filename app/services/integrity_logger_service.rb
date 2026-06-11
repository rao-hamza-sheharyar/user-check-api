class IntegrityLoggerService
  def initialize(idfa:, ban_status:, ip:, rooted_device:, country:, proxy:, vpn:)
    @idfa = idfa
    @ban_status = ban_status
    @ip = ip
    @rooted_device = rooted_device
    @country = country
    @proxy = proxy
    @vpn = vpn
  end

  def call
    IntegrityLog.create!(
      idfa: @idfa,
      ban_status: @ban_status,
      ip: @ip,
      rooted_device: @rooted_device,
      country: @country,
      proxy: @proxy,
      vpn: @vpn
    )
  end
end
