$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'browser'
require 'win32ole'
require 'yaml'

module Excel
  class ExportExcel
    attr_accessor :browser
    attr_accessor :bugs
    attr_accessor :excel
    attr_accessor :workbook
    attr_accessor :worksheet
    attr_accessor :totalbugs
    attr_accessor :labrunsortedbybug

    def initialize e_browser
      e = Integration::Environment.new e_browser
      @browser = e.browser
    end

    def jira_login user = 'v-guhu', pwd = 'Ep@198512254'
      browser.goto 'https://jira/jira/login.jsp?'
      browser.text_field(:id => 'login-form-username').set user
      browser.text_field(:id => 'login-form-password').set pwd
      browser.input(:id => 'login-form-submit').click
    end

    def query_bugs
      browser.goto 'https://jira/jira/secure/IssueNavigator.jspa'
      if browser.a(:id => 'switchnavtype').exist?
        browser.a(:id => 'switchnavtype').click
      end

      load_bugs
      bugs_str = ''
      totalbugs.each() do |b|
        bugs_str += b.to_s + ','
      end
      bugs_str.chop!

      browser.textarea(:id => 'jqltext').set "ID in (#{bugs_str})"
      browser.input(:id => 'jqlrunquery').click
      browser.a(:id => 'viewOptions').click
      browser.a(:id => 'currentExcelFields').click
      #browser.close
    end

    def open_excel
     if File.exist?("#{Dir.pwd}/downloads/bugs.xls")
        File.delete("#{Dir.pwd}/downloads/bugs.xls")
     end
     sleep 5
     if File.exist?("#{Dir.pwd}/downloads/Expedia+JIRA.xls")
        File.rename("#{Dir.pwd}/downloads/Expedia+JIRA.xls", "#{Dir.pwd}/downloads/bugs.xls")
     else
        raise "can't find file 'Expedia+JIRA.xls'"
     end
      @excel = WIN32OLE.new('Excel.Application')
      @workbook = excel.Workbooks.Open("#{Dir.pwd}/downloads/bugs.xls")
      @excel.visible = true
      @worksheet =  @workbook.Worksheets(1)
    end

    def add_labrun
      last_row = worksheet.UsedRange.Rows.Count
      last_col = worksheet.UsedRange.Columns.Count
      worksheet.Cells(4, last_col).value = "LabrunID"
      puts "The used excel size is #{last_row} x #{last_col}"
      puts "Now add the hyperlink for every bug"
      p  labrunsortedbybug
      for i in 5...last_row
        bug =  worksheet.Cells(i, 3).value
        puts "start add tlabrun(s) hyperlink for bug #{bug}"
        labrunsortedbybug.each_pair() do |k, v|
          if bug == k
            data = HyperLinkData.new v.join(',')
            add_hyperlink(worksheet, i, last_col, data)
          end
        end
        puts "add tlabrun(s) hyperlink bug #{bug} finished."
      end
    end

    def load_bugs
      @bugs = YAML.load(File.read(File.join(File.dirname(__FILE__), "..", "files", "bugs.yml")))
      @totalbugs =  @bugs['totalbugs']
      @labrunsortedbybug =  @bugs['labrunsortedbybug']
    end

    def add_hyperlink(ws, row, col, data)
      ws.Hyperlinks.Add('Anchor'=> ws.Cells(row,col), # # insert into column 'c' on the row: ws.Range("$#c$#{row}"),
                        'Address'=> data.url,
                        'TexttoDisplay'=> data.name,
                        'ScreenTip'=> "Click to go to this URL #{data.url}"
      )
    end

    def serch_worksheet worksheet_name
      excel = WIN32OLE::connect('excel.Application')
      worksheet = nil
      excel.Workbooks.each{|wb| # loop through all excel workbooks (i.e. open documents)
        wb.Worksheets.each{|ws| # loop through each workbook's worksheets
        if ws.name == worksheet_name
          worksheet = ws
          break
        end
        }
        break unless worksheet.nil?
      }
    end

    def save
      excel.Save
    end

    def close
      excel.Close
    end

  end

  class HyperLinkData
    attr_accessor :name
    attr_accessor :url
    def initialize labrun_numbers
      @url = 'http://tfx/LabrunManager/default.aspx?_labrunId=' + labrun_numbers
      @name = labrun_numbers.gsub(',', '  ')
    end
  end

end