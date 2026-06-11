require "rails_helper"

RSpec.describe VpnApiService do
  describe "#call" do
    subject(:service_call) { described_class.new(ip: ip).call }

    let(:ip) { "8.8.8.8" }
    let(:cache_key) { "vpnapi:#{ip}" }

    before do
      $redis.del(cache_key)

      allow(ENV).to receive(:fetch).and_call_original

      allow(ENV).to receive(:fetch)
        .with("VPNAPI_KEY")
        .and_return("test-key")
    end

    context "when VPN result exists in Redis cache" do
      before do
        $redis.set(
          cache_key,
          {
            vpn: false,
            proxy: false,
            tor: false
          }.to_json,
          ex: 24.hours
        )
      end

      it "returns the cached result" do
        expect(service_call).to eq(
          vpn: false,
          proxy: false,
          tor: false
        )
      end

      it "does not call VPNAPI" do
        expect(Faraday).not_to receive(:get)

        service_call
      end
    end

    context "when Redis cache is missing" do
      let(:vpnapi_response) do
        instance_double(
          Faraday::Response,
          success?: true,
          body: {
            security: {
              vpn: true,
              proxy: false,
              tor: false
            }
          }.to_json
        )
      end

      before do
        allow(Faraday).to receive(:get).and_return(vpnapi_response)
      end

      it "calls VPNAPI" do
        service_call

        expect(Faraday).to have_received(:get)
      end

      it "returns parsed VPNAPI data" do
        expect(service_call).to eq(
          vpn: true,
          proxy: false,
          tor: false
        )
      end

      it "stores the result in Redis" do
        service_call

        cached_result = JSON.parse(
          $redis.get(cache_key)
        )

        expect(cached_result).to eq(
          "vpn" => true,
          "proxy" => false,
          "tor" => false
        )
      end
    end

    context "when VPNAPI returns an unsuccessful response" do
      before do
        allow(Faraday).to receive(:get).and_return(
          instance_double(
            Faraday::Response,
            success?: false
          )
        )
      end

      it "returns a passed response" do
        expect(service_call).to eq(
          vpn: false,
          proxy: false,
          tor: false
        )
      end
    end

    context "when VPNAPI raises a connection error" do
      before do
        allow(Faraday).to receive(:get).and_raise(
          Faraday::ConnectionFailed.new("connection failed")
        )
      end

      it "returns a passed response" do
        expect(service_call).to eq(
          vpn: false,
          proxy: false,
          tor: false
        )
      end
    end
  end
end
