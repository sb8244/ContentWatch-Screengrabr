require 'spec_helper'

# Because this is a Singleton, we must call Singleton.__init__ before any call to .instance
describe SeleniumFirefoxPool do
  
  # Randomize the size of the pool to not have configuration bound tests
  let(:size) { rand(10) + 1 }
  before { ContentWatch::Application.config.selenium_firefox_pool[:size] = size }

  it "blocks new" do
    expect{
      SeleniumFirefoxPool.new
    }.to raise_error
  end

  context "with a mock driver" do
    let(:mock_driver) { double("Selenium Driver") }
    let(:mock_headless) { double("headless") }
    before(:each) { Selenium::WebDriver.should_receive(:for).exactly(size).times.and_return(mock_driver) }
    before(:each) { Headless.should_receive(:new).exactly(size).times.and_return(mock_headless) }
    before(:each) { mock_headless.should_receive(:start).exactly(size).times }

    it "initializes size drivers" do
      Singleton.__init__(SeleniumFirefoxPool)
      SeleniumFirefoxPool.instance
    end

    it "quits all instances" do
      Singleton.__init__(SeleniumFirefoxPool)

      mock_driver.should_receive(:quit).exactly(size).times
      mock_headless.should_receive(:destroy).exactly(size).times
      SeleniumFirefoxPool.instance
      SeleniumFirefoxPool.finalize.call
    end

    describe "get_driver" do
      it "with a free driver" do
        Singleton.__init__(SeleniumFirefoxPool)

        driver = SeleniumFirefoxPool.instance.get_driver
        expect(driver).to be_a(double.class)
      end

      it "nil when no free driver" do
        Singleton.__init__(SeleniumFirefoxPool)

        size.times { SeleniumFirefoxPool.instance.get_driver }
        driver = SeleniumFirefoxPool.instance.get_driver
        expect(driver).to be(nil)
      end
    end

    describe "free_driver" do
      it "frees a driver" do
        Singleton.__init__(SeleniumFirefoxPool)

        taken = nil
        size.times { taken = SeleniumFirefoxPool.instance.get_driver }
        driver = SeleniumFirefoxPool.instance.get_driver
        expect(driver).to be(nil)

        SeleniumFirefoxPool.instance.free_driver(taken)
        driver = SeleniumFirefoxPool.instance.get_driver
        expect(driver).to be_a(double.class)
      end
    end
  end
end