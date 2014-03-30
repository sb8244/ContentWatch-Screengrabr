require 'spec_helper'

describe RequestsController do
  let(:params) { { url: "www.google.com", selector: "#selector", callback: "www.other.com" } }

  describe "POST create" do

    context "with proper params" do
      it "creates an async job" do
        expect{
          post :create, params
        }.to change{ Resque.size(:screengrabs) }.by(1)
      end
    end

    context "without url and selector" do
      it "doesn't add a job" do
        expect{
          post :create
        }.not_to change{ Resque.size(:screengrabs) }
      end

      it "returns a bad_request(400)" do
        post :create
        expect(response.status).to eq(400)
      end
    end
  end

end
