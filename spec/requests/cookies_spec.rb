require 'rails_helper'

RSpec.describe "Cookies", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/cookies/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/cookies/show"
      expect(response).to have_http_status(:success)
    end
  end

end
