require 'rails_helper'

RSpec.describe "GET /api/v1/quotes/:tag", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.generate_access_token! }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }
  let(:quotes) { [ { "quote" => "A quote", "author" => "Someone", "author_about" => "", "tags" => [ "love" ] } ] }

  before do
    host! "localhost"
    User.destroy_all
    allow_any_instance_of(QuoteFetcherService).to receive(:call).and_return(quotes)
  end

  after { User.destroy_all }

  context "with valid token" do
    it "returns quotes" do
      get "/api/v1/quotes/love", headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["quotes"]).to eq(quotes)
    end
  end

  context "without token" do
    it "returns unauthorized" do
      get "/api/v1/quotes/love"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
