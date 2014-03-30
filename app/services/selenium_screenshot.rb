class SeleniumScreenshot
  @@padding = 30

  attr_reader :driver

  # Must pass in a driver arg with a Selenium based driver
  def initialize(args = {})
    @driver = args[:driver] || SeleniumFirefoxPool.instance.get_driver
  end

  def for(url)
    url = "http://#{url}" unless /^(http:\/\/|https:\/\/)/ =~ url
    @driver.navigate.to(url)
    self
  end

  def by_selector(selector)
    matches = @driver.find_elements(:css, selector)
    if matches.size > 0
      # Only process the first match
      el = matches[0]
      @location = el.location
      @size = el.size
    end
    matches.size > 0
  end

  def save!(name)
    unless @location.nil? || @size.nil?
      @driver.save_screenshot(name)
      image = ChunkyPNG::Image.from_file(name)
      image.crop!(@location.x - @@padding/2, @location.y - @@padding/2, @size.width + @@padding, @size.height + @@padding)
      image.save(name)
    else
      false
    end
  end

  def free
    SeleniumFirefoxPool.instance.free_driver(@driver)
  end
end