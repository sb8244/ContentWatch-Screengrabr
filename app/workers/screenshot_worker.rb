class ScreenshotWorker
  @queue = :screengrabs

  def self.perform(url, selector, callback)
    Rails.logger.info "#{url} #{selector} beginning to process"
    ss = SeleniumScreenshot.new
    name = Digest::SHA1.hexdigest([Time.now, rand].join)
    name += Digest::SHA1.hexdigest([Time.now, rand].join)

    file_location = Rails.root.join("tmp/images/#{name}.png").to_s
    if ss.for(url).by_selector(selector)
      begin
        ss.save!(file_location)

        f = File.new(file_location)
        SnipUploader.new.store!(f)
        File.delete(f.path)
        Rails.logger.info "#{name} uploaded to s3"
      rescue StandardError => e
        Rails.logger.error "#{url} #{selector}: #{e}"
      end
    else
      Rails.logger.info "#{name}: no selector matches"
    end

    ss.free
  end

end