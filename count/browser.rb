
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
          @browser = Watir::Browser.new 'firefox'
        when 'CHROME', 'chrome'
          require 'watir-webdriver'
          @browser = Watir::Browser.new 'chrome'
        else
          raise 'unsupported browser type.'
      end
    end

  end

end