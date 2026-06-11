require "rails_helper"

RSpec.describe "V1::Users", type: :request do
  describe "POST /v1/user/check_status" do
    subject(:make_request) do
      post "/v1/user/check_status",
           params: request_body.to_json,
           headers: headers
    end

    let(:request_body) do
      {
        idfa: idfa,
        rooted_device: rooted_device
      }
    end

    let(:headers) do
      {
        "CONTENT_TYPE" => "application/json",
        "CF-IPCountry" => country,
        "CF-Connecting-IP" => ip
      }
    end

    let(:idfa) { "request-user" }
    let(:rooted_device) { false }
    let(:country) { "GB" }
    let(:ip) { "8.8.8.8" }

    before do
      User.delete_all
      IntegrityLog.delete_all

      $redis.del("country_whitelist")
      $redis.sadd("country_whitelist", "GB")

      allow(VpnApiService).to receive_message_chain(:new, :call).and_return(
        { vpn: false, proxy: false, tor: false }
      )
    end

    context "when all checks pass" do
      it "returns HTTP 200" do
        make_request

        expect(response).to have_http_status(:ok)
      end

      it "returns not_banned" do
        make_request

        expect(JSON.parse(response.body)).to eq(
          "ban_status" => "not_banned"
        )
      end

      it "creates a user record" do
        expect { make_request }.to change(User, :count).by(1)
      end
    end

    context "when device is rooted" do
      let(:rooted_device) { true }

      it "returns banned" do
        make_request

        expect(JSON.parse(response.body)).to eq(
          "ban_status" => "banned"
        )
      end
    end

    context "when country is not whitelisted" do
      let(:country) { "RU" }

      it "returns banned" do
        make_request

        expect(JSON.parse(response.body)).to eq(
          "ban_status" => "banned"
        )
      end
    end

    context "when VPNAPI reports VPN usage" do
      before do
        allow(VpnApiService).to receive_message_chain(:new, :call).and_return(
          { vpn: true, proxy: false, tor: false }
        )
      end

      it "returns banned" do
        make_request

        expect(JSON.parse(response.body)).to eq(
          "ban_status" => "banned"
        )
      end
    end
  end
end