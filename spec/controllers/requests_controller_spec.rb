require 'spec_helper'

describe RequestsController do
  let(:params) { { url: "www.google.com", selector: "#selector", callback: "www.other.com" } }

  describe "POST create" do

    context "with proper params" do
      before { ResqueSpec.reset! }

      it "creates an async job" do
        post :create, params
        expect(ScreenshotWorker).to have_queued(params).in(:screengrabs)
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
