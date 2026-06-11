require "rails_helper"

RSpec.describe IntegrityLog, type: :model do
  describe "validations" do
    subject(:log) do
      described_class.new(
        idfa: idfa,
        ban_status: ban_status
      )
    end

    let(:idfa) { "log-user" }
    let(:ban_status) { "not_banned" }

    context "with valid attributes" do
      it "is valid" do
        expect(log).to be_valid
      end
    end

    context "without idfa" do
      let(:idfa) { nil }

      it "is invalid" do
        expect(log).not_to be_valid
      end
    end

    context "without ban_status" do
      let(:ban_status) { nil }

      it "is invalid" do
        expect(log).not_to be_valid
      end
    end
  end
end
