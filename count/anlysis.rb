$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'browser'

module Anlysis

  APE     = ['HP_webdriver','PLP_webdriver','pw_PLP','pw_HOME','e3homepage','All_Inclusive']
  HFCAO   = ['pw_FLP','pw_HLP','FLP_webdriver','HLP_webdriver','cx_fusion_IPSniff','OPD']
  FAT     = ['AirUI_OneWay','Flight UDP','Package UDP','TG']
  HHES    = ['EWEIntegration','Hotel_Core_E2E','ski_store_page','HE2E']
  HSF     = ['AirUI_MultiDest','APAC_BVT','Global_Footer','Header_webdriver','APAC_Smoke','AirUI_RoundTrip','AirUI_OneWay_Filter_Cucumber']
  HOUC    = ['Opaque_Hotel','Hotel_Search_Results','UDP_Opaque','Opaque UDP Live','OSR','HSR Live','Car_Launch_Page']
  PAI     = ['PackageSOA','Package Signoff']
  STA     = ['AirUI_RoundTrip', 'StreamlineInfosite','AirUI_Cucumber','Infosite Live Regression','Airui','Infosite Live Acceptance','Airui_RoundTrip']

  DIFF1   = 'AirUI_OneWay'
  DIFF2   = 'AirUI_OneWay_Filter_Cucumber'


  class LabrunAnLysis

    attr_reader   :browser
    attr_accessor :result
    attr_accessor :labruns

    def initialize
      e         = Integration::Environment.new
      @browser  = e.browser
      @result   = Hash.new
    end

    def get_labruns file
      @labruns = IO.readlines(file)
    end

    def start_anlysis
      browser.goto labruns[0]
      container = browser.table(:class => "DefaultGrid")

      begin
        container.wait_until_present
      rescue Watir::Wait::TimeoutError
        $stderr.puts("waiting for labruns #{labruns} load failed after 60s at #{Time.new.to_s}")
      end

      ape    = Array.new
      hfcao  = Array.new
      fat    = Array.new
      hhes   = Array.new
      hsf    = Array.new
      houc   = Array.new
      pai    = Array.new
      sta    = Array.new

      anlysis_sub_page(ape, hfcao, fat, hhes, hsf, houc, pai, sta, container)

      k = 2
      while container.table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).exist?
        container.table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).click
        sleep 2
        k  += 1
        anlysis_sub_page(ape, hfcao, fat, hhes, hsf, houc, pai, sta, container)
      end

      result['APE']   = ape
      result['HFCAO'] = hfcao
      result['FAT']   = fat
      result['HHES']  = hhes
      result['HSF']   = hsf
      result['HOUC']  = houc
      result['PAI']   = pai
      result['STA']   = sta

      browser.close
    end

    def anlysis_sub_page(ape, hfcao, fat, hhes, hsf, houc, pai, sta, container)
      i = 0
      loop do
        if container.a(:id => /tfx_TfxContent_LabRunsGridView_ctl(\d+)_LabRunNameLink/, :index => i).exist?
          labrun = container.a(:id => /tfx_TfxContent_LabRunsGridView_ctl(\d+)_LabRunNameLink/, :index => i).attribute_value("href")
          labrun =~ /=/
          labrun = $'
          name = container.a(:id => /tfx_TfxContent_LabRunsGridView_ctl(\d+)_LabRunNameLink/, :index => i).text

          flag = false
          APE.each do |v|
            if name.include?(v)
              flag = true
              ape << labrun
              break
            end
          end

          if !flag
            HFCAO.each do |v|
              if name.include?(v)
                flag = true
                hfcao << labrun
                break
              end
            end
          end

          if !flag
            FAT.each do |v|
              if v == DIFF1
                if (name.include?(v) && !name.include?(DIFF2))
                   flag = true
                   fat << labrun
                   break
                end
              else
                if name.include?(v)
                   flag = true
                   fat << labrun
                   break
                 end
              end
            end
          end

          if !flag
            HHES.each do |v|
              if name.include?(v)
                flag = true
                hhes << labrun
                break
              end
            end
          end

          if !flag
            HSF.each do |v|
              if name.include?(v)
                flag = true
                hsf << labrun
                break
              end
            end
          end

          if !flag
            HOUC.each do |v|
              if name.include?(v)
                flag = true
                houc << labrun
                break
              end
            end
          end

          if !flag
            PAI.each do |v|
              if name.include?(v)
                flag = true
                pai << labrun
                break
              end
            end
          end

          if !flag
            STA.each do |v|
              if name.include?(v)
                flag = true
                sta << labrun
                break
              end
            end
          end

          i += 1
        else
          break
        end

      end
    end

    def construct_ape_source
      r = '
<h4>All-Inclusive-Vacations & Packages Launch & E3 Home Page Report</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['APE'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def construct_hfcao_source
      r = '
<h4>Flight launch page, Hotel launch page, CX_Fusion_IPSniff, Ad Placements and OPD</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['HFCAO'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def construct_fat_source
      r = '
<h4>Flight UDP & AirUI OneWay&TG smoke</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['FAT'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def construct_hhes_source
      r = '
<h4>HE2E Checkout,Hotel_Core_E2E_Smoke,EWEIntegration_Book_For expWeb,and SKI Store</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['HHES'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def construct_hsf_source
      r = '
<h4>Header, SEO Global Footer and Flight result_Filters</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['HSF'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def construct_houc_source
      r = '
<h4>Hotel skinny SR ,Opaque Hotel,UDP Opaque Hotel (HE2E) and CLP</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['HOUC'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def construct_pai_source
      r = '
<h4>Package SOA&Infosite</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['PAI'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def construct_sta_source
      r = '
<h4>Streamlined Hotel Infosite&Air UI Improvement</h4>
<a href="http://tfx/LabrunManager/default.aspx?_labrunId='
      s = ''
      result['STA'].each do |v|
        s.concat(v.to_s+',')
      end
      r.concat(s.chop+'">'+s.chop+'</a>')
    end

    def output_result file_name
      $stdout.puts "Writing labrun anlysis to file #{file_name}..."
      File.open(file_name, "w") do |file|
        file.puts '
<html>
<head>
    <title>Labrun Anlysis Result</title>
</head>
<body style="background-color: #FCD20A;color:green;">
'
        file.puts construct_ape_source
        file.puts construct_hfcao_source
        file.puts construct_fat_source
        file.puts construct_hhes_source
        file.puts construct_hsf_source
        file.puts construct_houc_source
        file.puts construct_pai_source
        file.puts construct_sta_source
        file.puts '
</body>
</html>'
        $stdout.puts "Finished write labrun anlysis result to file #{file}"
      end
    end

  end
end