require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject(:user) { described_class.new(idfa: idfa, ban_status: ban_status) }

    let(:idfa) { "model-user" }
    let(:ban_status) { "not_banned" }

    context "with valid attributes" do
      it "is valid" do
        expect(user).to be_valid
      end
    end

    context "without idfa" do
      let(:idfa) { nil }

      it "is invalid" do
        expect(user).not_to be_valid
      end
    end

    context "without ban_status" do
      let(:ban_status) { nil }

      it "is invalid" do
        expect(user).not_to be_valid
      end
    end

    context "with invalid ban_status" do
      let(:ban_status) { "invalid_status" }

      it "is invalid" do
        expect(user).not_to be_valid
      end
    end
  end

  describe "#banned?" do
    context "when ban_status is banned" do
      it "returns true" do
        user = described_class.new(idfa: "banned-user", ban_status: "banned")

        expect(user.banned?).to eq(true)
      end
    end

    context "when ban_status is not_banned" do
      it "returns false" do
        user = described_class.new(idfa: "safe-user", ban_status: "not_banned")

        expect(user.banned?).to eq(false)
      end
    end
  end
end

