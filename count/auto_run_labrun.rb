$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'browser'

class AutoRunLabrun

  attr_reader   :browser
  attr_accessor :labruns

  def initialize
    e         = Integration::Environment.new
    @browser  = e.browser
  end

  def get_labruns file
    @labruns = IO.readlines(file)
  end

  def run
    browser.goto labruns[0]
    container = browser.table(:class => "DefaultGrid")
    check_sub_page container
    k = 2
    while container.table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).exist?
      container.table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).click
      sleep 2
      k  += 1
      check_sub_page container
    end
    linkbar = browser.div(:class => 'LinksBar')
    rerun_fail_link = linkbar.a(:id => 'tfx_TfxContent_RerunFailedAssignmentsLink')
    rerun_fail_link.click
  end

  def check_sub_page container
    i = 0
    loop do
      row_exist = container.tr(:class => /DefaultGridAltRow|DefaultGridRow/, :index => i).exist?
      if row_exist
        row = container.tr(:class => /DefaultGridAltRow|DefaultGridRow/, :index => i)
        checkbox = row.input(:id => /tfx_TfxContent_LabRunsGridView_ctl(\d+)_LabRunIdCheckBox/)
        finish_status = row.td(:id => 'LabRunsGridView_BoundField_DisplayStatus').text
        pass_fail_html = row.span(:class => 'PassFailStatusPill').html
        pass = (pass_fail_html =~ /Pass:&#9;&#9;100%/)

        if (finish_status == 'Complete' && !pass)
          $stdout.puts "The #{i}th labrun status is Complete and failed, select it"
          checkbox.click
        elsif (finish_status == 'Complete' && pass)
          $stdout.puts "The #{i}th labrun status is Complete and passed, ignore it"
        elsif (finish_status == 'Not Started')
          $stdout.puts "The #{i}th labrun status is not started, select it"
          checkbox.click
        elsif ((finish_status != 'Complete')&&(finish_status != 'Not Started'))
          $stdout.puts "The #{i}th labrun status is not Complete, ignore it"
        end
        i += 1
      else
        break
      end
    end
  end

end