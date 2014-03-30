class RequestsController < ApplicationController

  def create
    url = params[:url]
    selector = params[:selector]
    web_callback = params[:callback]

    if url.blank? || selector.blank?
      render status: :bad_request, json: { message: "URL and Selector are required but not given" }
    else
      Resque.enqueue(ScreenshotWorker, params)
      render json: { status: "queued" }
    end
  end

end