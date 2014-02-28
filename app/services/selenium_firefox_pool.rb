class SeleniumFirefoxPool
  # This is a singleton because there should only be the defined number of FF instances running
  include Singleton

  # Pool must be a class instance to allow for freeing of resources at end
  @@pool = []

  # Synchronize access to the get_driver and free_driver critical sections
  @@semaphore = Mutex.new

  def initialize(args = {})
    # Must define a finalizer so that all instances can be freed
    ObjectSpace.define_finalizer(self, self.class.finalize)

    size = ContentWatch::Application.config.selenium_firefox_pool[:size]
    initialize_pool(size)
  end

  # close the pool on exit
  def self.finalize
    proc do 
      @@pool.each do |entry|
        entry[:driver].quit
        unless Rails.env.development?
          entry[:headless].destroy
        end
      end
    end
  end

  # Grab a free driver from the pool and then mark that driver as taken
  def get_driver
    @@semaphore.synchronize do
      @@pool.each do |entry|
        unless entry[:taken]
          entry[:taken] = true
          return entry[:driver]
        end
      end
    end
    nil
  end

  # Return a driver back into the pool and mark that driver as free
  def free_driver(driver)
    @@semaphore.synchronize do
      @@pool.each do |entry|
        if entry[:driver] == driver
          entry[:taken] = false
        end
      end
    end
    nil
  end

  private
    def initialize_pool(size)
      @@pool = []
      size.times do 
        entry = {}
        #Ignored only in development, mocked in test, live in production
        unless Rails.env.development?
          entry[:headless] = Headless.new(display: @@pool.size)
          entry[:headless].start
        end
        entry[:driver] = get_new_selenium
        entry[:taken] = false
        @@pool << entry
      end
    end

    def get_new_selenium
      Selenium::WebDriver.for :firefox, profile: get_profile
    end

    # define the firefox profile that 
    def get_profile
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.folderList'] = 2
      profile['browser.download.manager.showWhenStarting'] = false
      # don't save any downloads to disk, just erase it
      profile['browser.download.dir'] = '/dev/null'
      # don't do a download popup or it could interfere with future requests
      profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/x-xpinstall;application/x-zip;application/x-zip-compressed;application/octet-stream;application/zip;application/pdf;application/msword;text/plain;application/octet'
      profile['browser.download.manager.showAlertOnComplete'] = false
      profile['browser.download.manager.showWhenStarting'] = false
      profile['browser.download.panel.shown'] = false
      profile['browser.download.useToolkitUI'] = true
      profile.assume_untrusted_certificate_issuer = false
      profile
    end
end