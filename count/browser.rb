$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

module Integration

  class Environment
    attr_accessor :browser

    def initialize(browser = 'ie')
      if !ENV['BROWSER'].nil?
        start ENV['BROWSER']
      else
        start browser
      end
    end

    def start(b)
      case b
        when 'IE', 'ie'
          require 'watir'
          @browser = Watir::Browser.new
        # TODO: add watir-webdriver supported
        when 'FIREFOX', 'firefox'
          require 'watir-webdriver'
          download_directory = "#{Dir.pwd}/downloads"
          download_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?

          profile = Selenium::WebDriver::Firefox::Profile.new
          profile['browser.download.folderList'] = 2 # custom location
          profile['browser.download.dir'] = download_directory
          profile['browser.helperApps.neverAsk.saveToDisk'] = "text/csv,application/pdf"

          @browser = Watir::Browser.new :firefox, :profile => profile
        when 'CHROME', 'chrome'
          require 'watir-webdriver'
          ENV["PATH"] = File.expand_path File.join(File.dirname(__FILE__), '..', 'driver')
          http_client = Selenium::WebDriver::Remote::Http::Default.new
          http_client.timeout = 120
          download_directory = "#{Dir.pwd}/downloads"
          download_directory.gsub!("/", "\\") if  Selenium::WebDriver::Platform.windows?

          profile = Selenium::WebDriver::Chrome::Profile.new
          profile['download.prompt_for_download'] = false
          profile['download.default_directory'] = download_directory

          @browser = Watir::Browser.new :chrome, :profile => profile, :http_client => http_client, :switches => %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate]
        else
          raise 'unsupported browser type.'
      end
    end

  end

end