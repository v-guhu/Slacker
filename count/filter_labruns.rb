$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'browser'

module Filter

  class TrunkFilter
    attr_reader   :browser
    attr_accessor :result
    attr_accessor :tier0
    attr_accessor :ship_stopper
    attr_accessor :ship_stopper_
    attr_accessor :labruns
    attr_accessor :date
    attr_accessor :stop

    COMMON = ['EBR_Smoke_Tier0_Dynamic_Copy', 'AARPe2eHotel_Tier0_Dynamic']
    SHIP_STOPPER = ['facebook_end_to_end', 'Regress package ship stopper bug', 'Guest upgrade booking into existing account', 'TG_04_R1_Shipstopper_92360']

    def initialize
      e               = Integration::Environment.new
      @browser        = e.browser
      @result         = Hash.new
      @tier0          = Hash.new
      @ship_stopper   = Hash.new
      @ship_stopper_  = Hash.new
      @stop           = false
      @date           = ''
    end

    def open_url(url = 'http://lrm/default.aspx?_createdBy=v-guhu&_environmentName=trunk_cx_vips')
      browser.goto url
    end

    def filter
      open_url

      if browser.table(:class => 'DefaultGrid').visible?
        container = browser.table(:class => "DefaultGrid")
      end
      filter_in_subpage(container)

      k = 2
      while container.table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).exist?
        container.table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).click
        sleep 2
        k  += 1
        filter_in_subpage(container)
        if stop
          break
        end
      end
      browser.close
    end

    def filter_in_subpage(container)
      i = 0
      loop do
        if !container.a(:id => /tfx_TfxContent_LabRunsGridView_ctl(\d+)_LabRunNameLink/, :index => i).exists?
          break
        end
        name_str = container.a(:id => /tfx_TfxContent_LabRunsGridView_ctl(\d+)_LabRunNameLink/, :index => i).text
        name = modify_name(name_str)
        labrunid = container.td(:id => 'LabRunsGridView_BoundField_LabRunId', :index => i).text

        if @date == ''
          date_str = container.td(:id => 'LabRunsGridView_BoundField_StartDate', :index => 0).text
          @date = date_str.split(' ')[0]
        end

        temp_date_str = container.td(:id => 'LabRunsGridView_BoundField_StartDate', :index => i).text
        temp_date = temp_date_str.split(' ')[0]
        if date !=  temp_date
          @stop = true
          break
        else
          @result[labrunid] = name
        end
        i = i + 1
      end
      @result
    end

    def process_result
      common = Hash.new
      @result.each_pair do |k, v|
        if !v.include?('tier1')
          if SHIP_STOPPER.include?(v) && !@ship_stopper.has_key?(v)
            @ship_stopper[v] = k
            @ship_stopper_[v] = k
          elsif COMMON.include?(v) && !common.has_key?(v)
            common[k] = v
          elsif !@tier0.has_key?(v)
            @tier0[v] = k
          end
        end
      end      
      
      c = sort_hash_by_value(common)
      c.each_pair do |k, v|
        if v.size == 2
          if !@tier0.has_key?(k)
            @tier0[k] = v[0]
            @ship_stopper_[k] = v[0] 
          end

          if !@ship_stopper.has_key?(k)
            @ship_stopper[k] = v[1]                       
          end
        else
          if !@tier0.has_key?(k)
            @tier0[k] = v[0]
          end
        end
      end      
    end

    def sort_hash_by_value hash_table
      h = Hash.new
      hash_table.each_pair do |k, v|
        if h.has_key?(v)
          h[v] = h[v] << k
        else
          h[v] = [] << k
        end
      end
      return h
    end

    def get_labruns_str
      process_result
      prefix = 'http://lrm/default.aspx?_labrunId='
      tier0_url, ship_stopper_url, ship_stopper_url_ = prefix, prefix, prefix

      @tier0.each_value do |v|
        tier0_url +=  v + ','
      end
      tier0_url.chop!

      @ship_stopper.each_value do |v|
        ship_stopper_url +=  v + ','
      end 
      ship_stopper_url.chop!
      
      @ship_stopper_.each_value do |v|
        ship_stopper_url_ +=  v + ','
      end
      ship_stopper_url_.chop!
      
      str ="
Tier0 total #{@tier0.size}:
#{tier0_url}

ShipStopper(two labruns are same as trunk) total: #{@ship_stopper_.size}:
#{ship_stopper_url_}

ShipStopper(two labruns are different from trunk) total: #{@ship_stopper.size}:
#{ship_stopper_url}
"
      return str
    end

    def modify_name name
      name.split('_TRUNK_CX_VIPS_')[0]
    end

    def write_result file_name
      $stdout.puts "Write result to file #{file_name}..."
      File.open(file_name, "w") do |file|
        file.puts get_labruns_str
        $stdout.puts "Write result to file #{file_name} completed"
      end
    end

  end
end