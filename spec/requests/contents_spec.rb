require 'rails_helper'

RSpec.describe "Contents", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/contents/index"
      expect(response).to have_http_status(:success)
    end
  end
end
