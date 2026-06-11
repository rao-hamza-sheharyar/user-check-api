require "rails_helper"

RSpec.describe UserCheckStatusService do
  describe "#call" do
    subject(:service_call) do
      described_class.new(
        idfa: idfa,
        rooted_device: rooted_device,
        ip: ip,
        country: country
      ).call
    end

    let(:idfa) { "test-user-1" }
    let(:rooted_device) { false }
    let(:ip) { "8.8.8.8" }
    let(:country) { "GB" }
    let(:vpn_result) { { vpn: false, proxy: false, tor: false } }

    before do
      User.delete_all
      IntegrityLog.delete_all

      $redis.del("country_whitelist")
      $redis.sadd("country_whitelist", "GB")

      allow(VpnApiService).to receive_message_chain(:new, :call).and_return(vpn_result)
    end

    context "when all security checks pass" do
      it "returns not_banned" do
        expect(service_call).to eq("not_banned")
      end

      it "creates a not_banned user" do
        service_call

        user = User.find_by(idfa: idfa)

        expect(user).to be_present
        expect(user.ban_status).to eq("not_banned")
      end

      it "creates an integrity log" do
        expect { service_call }.to change(IntegrityLog, :count).by(1)

        log = IntegrityLog.last

        expect(log.idfa).to eq(idfa)
        expect(log.ban_status).to eq("not_banned")
        expect(log.ip).to eq(ip)
        expect(log.rooted_device).to eq(false)
        expect(log.country).to eq("GB")
        expect(log.proxy).to eq(false)
        expect(log.vpn).to eq(false)
      end
    end

    context "when the device is rooted" do
      let(:rooted_device) { true }

      it "returns banned" do
        expect(service_call).to eq("banned")
      end

      it "creates a banned user" do
        service_call

        expect(User.find_by(idfa: idfa).ban_status).to eq("banned")
      end

      it "creates an integrity log without VPN data because VPN check is skipped" do
        service_call

        log = IntegrityLog.last

        expect(log.ban_status).to eq("banned")
        expect(log.rooted_device).to eq(true)
        expect(log.proxy).to be_nil
        expect(log.vpn).to be_nil
      end
    end

    context "when country is not whitelisted" do
      let(:country) { "RU" }

      it "returns banned" do
        expect(service_call).to eq("banned")
      end

      it "does not call VPNAPI because country check already failed" do
        expect(VpnApiService).not_to receive(:new)

        service_call
      end
    end

    context "when VPNAPI reports VPN usage" do
      let(:vpn_result) { { vpn: true, proxy: false, tor: false } }

      it "returns banned" do
        expect(service_call).to eq("banned")
      end

      it "stores VPN result in integrity log" do
        service_call

        log = IntegrityLog.last

        expect(log.vpn).to eq(true)
        expect(log.proxy).to eq(false)
      end
    end

    context "when VPNAPI reports proxy usage" do
      let(:vpn_result) { { vpn: false, proxy: true, tor: false } }

      it "returns banned" do
        expect(service_call).to eq("banned")
      end
    end

    context "when VPNAPI reports Tor usage" do
      let(:vpn_result) { { vpn: false, proxy: false, tor: true } }

      it "returns banned" do
        expect(service_call).to eq("banned")
      end
    end

    context "when an existing not_banned user returns with same status" do
      before do
        described_class.new(
          idfa: idfa,
          rooted_device: false,
          ip: ip,
          country: "GB"
        ).call
      end

      it "does not create another integrity log" do
        expect { service_call }.not_to change(IntegrityLog, :count)
      end
    end

    context "when an existing not_banned user becomes banned" do
      before do
        described_class.new(
          idfa: idfa,
          rooted_device: false,
          ip: ip,
          country: "GB"
        ).call
      end

      let(:rooted_device) { true }

      it "updates the user status to banned" do
        service_call

        expect(User.find_by(idfa: idfa).ban_status).to eq("banned")
      end

      it "creates a new integrity log" do
        expect { service_call }.to change(IntegrityLog, :count).by(1)
      end
    end

    context "when user is already banned" do
      before do
        User.create!(idfa: idfa, ban_status: "banned")
      end

      it "returns banned immediately" do
        expect(service_call).to eq("banned")
      end

      it "does not run VPNAPI check" do
        expect(VpnApiService).not_to receive(:new)

        service_call
      end

      it "does not create a new integrity log" do
        expect { service_call }.not_to change(IntegrityLog, :count)
      end
    end
  end
end
