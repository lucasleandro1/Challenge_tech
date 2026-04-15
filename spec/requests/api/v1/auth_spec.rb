require "rails_helper"

RSpec.describe "Auth", type: :request do
  before do
    host! "localhost"
    User.destroy_all
  end

  after { User.destroy_all }

  describe "POST /api/v1/auth/sign_up" do
    context "with valid params" do
      it "creates a user and returns a token" do
        post "/api/v1/auth/sign_up", params: { email: "new@example.com", password: "password123" }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key("token")
      end
    end

    context "with invalid params" do
      it "returns errors when email is missing" do
        post "/api/v1/auth/sign_up", params: { password: "password123" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to have_key("errors")
      end

      it "returns errors when email is already taken" do
        create(:user, email: "taken@example.com")
        post "/api/v1/auth/sign_up", params: { email: "taken@example.com", password: "password123" }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "POST /api/v1/auth/sign_in" do
    let!(:user) { create(:user, email: "login@example.com", password: "password123") }

    context "with valid credentials" do
      it "returns a token" do
        post "/api/v1/auth/sign_in", params: { email: "login@example.com", password: "password123" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key("token")
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized for wrong password" do
        post "/api/v1/auth/sign_in", params: { email: "login@example.com", password: "wrong" }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
      end

      it "returns unauthorized for unknown email" do
        post "/api/v1/auth/sign_in", params: { email: "unknown@example.com", password: "password123" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
