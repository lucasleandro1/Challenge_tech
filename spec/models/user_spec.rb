require 'rails_helper'

RSpec.describe User, type: :model do
  before { User.destroy_all }
  after  { User.destroy_all }

  describe "validations" do
    it "is valid with email and password" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is invalid without email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it "is invalid without password" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it "is invalid with duplicate email" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).not_to be_valid
    end
  end

  describe "#generate_access_token!" do
    it "generates and persists an access token" do
      user = create(:user)
      token = user.generate_access_token!
      expect(token).to be_present
      expect(user.reload.access_token).to eq(token)
    end

    it "generates a different token each time" do
      user = create(:user)
      token1 = user.generate_access_token!
      token2 = user.generate_access_token!
      expect(token1).not_to eq(token2)
    end
  end
end
