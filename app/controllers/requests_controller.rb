class RequestsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    params = requests_params
    if params[:url].blank? || params[:selector].blank?
      render status: :bad_request, json: { message: "URL and Selector are required but not given" }
    else
      Resque.enqueue(ScreenshotWorker, params)
      render json: { status: "queued" }
    end
  end

  private
    def requests_params
      { url: params[:url], selector: params[:selector], callback: params[:callback] }
    end
end