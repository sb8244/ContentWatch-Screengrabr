class ScreenshotWorker
  @queue = :screengrabs

  def self.perform(url, selector, callback)
    result = { url: url, selector: selector, status: 500 }

    ss = SeleniumScreenshot.new
    name = Digest::SHA1.hexdigest([Time.now, rand].join)
    name += Digest::SHA1.hexdigest([Time.now, rand].join)

    file_location = Rails.root.join("tmp/images/#{name}.png").to_s

    begin
      if ss.for(url).by_selector(selector)
          ss.save!(file_location)

          f = File.new(file_location)

          uploader = SnipUploader.new
          uploader.store!(f)
          File.delete(f.path)
          Rails.logger.info "#{name} uploaded to s3"

          result[:status] = 200
          result[:image] = uploader.url
      else
        # No selector matches
        result[:status] = 404
      end
    rescue StandardError => e
      Rails.logger.error "#{url} #{selector}: #{e}"
    end

    ss.free
    do_callback(callback, result)
  end

  private
    def self.do_callback(callback, data)
      callback = "http://#{callback}" unless callback.starts_with?("http://") || callback.starts_with?("https://")
      Net::HTTP.post_form(URI.parse(callback), data)
    end
end