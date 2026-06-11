require "rails_helper"

RSpec.describe IntegrityLoggerService do
  describe "#call" do
    subject(:service_call) do
      described_class.new(
        idfa: idfa,
        ban_status: ban_status,
        ip: ip,
        rooted_device: rooted_device,
        country: country,
        proxy: proxy,
        vpn: vpn
      ).call
    end

    let(:idfa) { "logger-user" }
    let(:ban_status) { "not_banned" }
    let(:ip) { "8.8.8.8" }
    let(:rooted_device) { false }
    let(:country) { "GB" }
    let(:proxy) { false }
    let(:vpn) { false }

    it "creates an integrity log" do
      expect { service_call }.to change(IntegrityLog, :count).by(1)
    end

    it "stores the provided security data" do
      service_call

      log = IntegrityLog.last

      expect(log.idfa).to eq(idfa)
      expect(log.ban_status).to eq(ban_status)
      expect(log.ip).to eq(ip)
      expect(log.rooted_device).to eq(rooted_device)
      expect(log.country).to eq(country)
      expect(log.proxy).to eq(proxy)
      expect(log.vpn).to eq(vpn)
    end
  end
end