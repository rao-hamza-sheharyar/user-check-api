require "faraday"
require "json"

class VpnApiService
  CACHE_TTL = 24.hours

  def initialize(ip:)
    @ip = ip
  end

  def call
    cached_response = cached_result
    return cached_response if cached_response.present?

    response = fetch_from_vpnapi
    cache_result(response)

    response
  rescue StandardError
    passed_response
  end

  private

  def cached_result
    cached = $redis.get(cache_key)
    return nil if cached.blank?

    JSON.parse(cached).symbolize_keys
  end

  def fetch_from_vpnapi
    response = Faraday.get("https://vpnapi.io/api/#{@ip}?key=#{ENV.fetch('VPNAPI_KEY')}")
    return passed_response unless response.success?

    body = JSON.parse(response.body)
    {
      vpn: body.dig("security", "vpn") == true,
      proxy: body.dig("security", "proxy") == true,
      tor: body.dig("security", "tor") == true
    }
  rescue StandardError
    passed_response
  end

  def cache_result(response)
    $redis.set(cache_key, response.to_json, ex: CACHE_TTL)
  end

  def cache_key
    "vpnapi:#{@ip}"
  end

  def passed_response
    {
      vpn: false,
      proxy: false,
      tor: false
    }
  end
end