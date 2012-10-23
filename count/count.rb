require 'browser'

module Count
  URL_PREFIX_LRM_DOWN      = 'http://lrm/default.aspx?labrunid='
  URL_PREFIX_LRM           = 'http://lrm/default.aspx?_labrunId='
  URL_PREFIX_LRM_RE        = 'http://lrm/LabRunReport.aspx?labrunid='
  URL_PREFIX_MULTIPLE      = 'http://tfx/LabrunManager/default.aspx?_labrunId='
  URL_PREFIX_SINGLE        = 'http://tfx/LabrunManager/LabRunReport.aspx?labrunid='
  URL_PREFIX_SINGLE_UPCASE = 'http://tfx/LabrunManager/LabRunReport.aspx?labrunId='

  class CountBugs
    attr_reader :browser
    attr_accessor :labrun_ids
    attr_reader :bugs
    attr_accessor :unfinished_labruns

    def initialize
      e                   = Integration::Environment.new
      @browser            = e.browser
      @labrun_ids         = Array.new
      @bugs               = Hash.new
      @unfinished_labruns = Array.new
    end

    def get_labrun_ids_from_file(file)
        data = IO.readlines(file)
        data.each do |a|
          a.strip!
          a.gsub!(URL_PREFIX_MULTIPLE, '')
          a.gsub!(URL_PREFIX_SINGLE_UPCASE, '')
          a.gsub!(URL_PREFIX_SINGLE, '')
          a.gsub!(URL_PREFIX_LRM, '')
          a.gsub!(URL_PREFIX_LRM_DOWN, '')
          a.gsub!(URL_PREFIX_LRM_RE, '')
          labrun_ids << a.split(',')
        end
        labrun_ids.flatten!.uniq! #.sort!
    end

    def count_bugs_in_single_labrun labrunid
      url =  URL_PREFIX_SINGLE + labrunid.to_s
      browser.goto url

      container = browser.table(:class => "DefaultGrid")
      begin
        container.wait_until_present
      rescue Watir::Wait::TimeoutError
        $stderr.puts("waiting for labrun #{url} load failed after 60s at #{Time.new.to_s}")
      end

      $stdout.puts "counting bug(s) in labrun #{url}..."
      results = Array.new

      html_text = container.html.gsub(/(AssignedTo)|(Assigned To)/, "")
      if html_text =~ /Queued|Assigned|Executing|None/
        return "Unfinished"
      end

      i=0
      loop do
        if browser.span(:id => /tfx_TfxContent_AssignmentDetailsGridView_ctl(\d+)_ErrorControl_ErrorDetailLabel/, :index => i).exist?
          full_description = browser.span(:id => /tfx_TfxContent_AssignmentDetailsGridView_ctl(\d+)_ErrorControl_ErrorDetailLabel/, :index => i).text
          full_description =~ /MAIN-(\d+)|QM-(\d+)|(INC(\d+))/i

          if "" == full_description
            return "Unfinished"
          end

          unless $&.nil?
            results << $&.upcase
          end
          i += 1
        else
          break
        end
      end

      k = 2
      while browser.table(:class => "DefaultGrid").table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).exist?
        browser.table(:class => "DefaultGrid").table(:class => "GridViewCurrButton").td(:class => "scott").link(:text => k.to_s).click
        sleep 2
        k  += 1
        i=0
        loop do
          if browser.span(:id => /tfx_TfxContent_AssignmentDetailsGridView_ctl(\d+)_ErrorControl_ErrorDetailLabel/, :index => i).exist?
            full_description = browser.span(:id => /tfx_TfxContent_AssignmentDetailsGridView_ctl(\d+)_ErrorControl_ErrorDetailLabel/, :index => i).text
            full_description =~ /MAIN-(\d+)|QM-(\d+)|(INC(\d+))/

            if "" == full_description
              return "Unfinished"
            end

            unless $&.nil?
              results << $&.upcase
            end
            i += 1
          else
            break
          end
        end
      end

      $stdout.puts "finished count bug(s) in labrun #{url}."
      return results.flatten.uniq.compact
    end

    def count_bugs_in_all_labruns file
      get_labrun_ids_from_file file
      labrun_ids.each() do |e|
        if "Unfinished" == count_bugs_in_single_labrun(e)
          unfinished_labruns << e
        else
          bugs[e] = count_bugs_in_single_labrun(e)
        end
      end
      browser.close
    end

    def write_bugs_to_file file_name
      $stdout.puts "Writing bugs to file #{file_name}..."
      File.open(file_name, "w") do |file|
        file.puts sort_bugs_by 'default'
        file.puts sort_bugs_by 'bug'
        file.puts sort_bugs_by 'labrun'
        file.puts sort_bugs_by 'jira'
        file.puts sort_bugs_by 'hawaii'
        file.puts get_unfinished_labrun_url
        $stdout.puts "Finished write bugs to file #{file_name}"
      end
    end

    def output_result_as_html file_name
      $stdout.puts "Output result as html file #{file_name}..."
      File.open(file_name, "w") do |file|
        file.puts '
<html>
<head>
    <title>Bug Count Result</title>
</head>
<body style="background-color: #FCD20A;color:green;">
'
        file.puts construct_total_bug_table
        file.puts construct_sorted_by_bug_table
        file.puts construct_sorted_by_labrun
        file.puts construct_jira_bug_table
        file.puts construct_hawaii_bug_table
        file.puts construct_unfinished_labrun_table
        file.puts '
</body>
</html>
'
        $stdout.puts "Finished output result to file #{file_name}"
      end
    end

    def construct_total_bug_table
      # 统计出所有的bug，放入total_bugs中
      total_bugs = Array.new
      bugs.each_value do |e|
        total_bugs << e
      end

      if total_bugs.size != 0
        total_bugs.flatten!
        total_bugs.uniq!
      end

      # 以字符串的形式返回结果
      s = '
<h4>Total Bugs: </h4>
<table>
    <tr>'
      total_bugs.each do |e|
        s.concat('
        <td><a href="https://jira/jira/browse/'+e.to_s+'">'+e.to_s+'</a> </td>')
      end
      s.concat('
    </tr>
</table>')
      return s
    end

    def construct_sorted_by_bug_table
      # 统计出所有的bug，放入total_bugs中
      total_bugs = Array.new
      bugs.each_value do |e|
        total_bugs << e
      end

      if total_bugs.size != 0
        total_bugs.flatten!
        total_bugs.uniq!
      end

      # 以bug号作为key，有此bug的所有LabrunID组成的数组作为value
      result_hash = Hash.new
      total_bugs.each() do |b|
        ta = Array.new
        bugs.each_pair do |k,v|
          if v.find_index(b)
            ta << k
          end
        end
        result_hash[b] = ta
      end

      # 以字符串的形式返回结果
      result = '
<h4>Labrun List Sorted By Bug:</h4>
<table>'
      result_hash.each_pair do |k, v|
        s = ''
        v.each do |e|
          s.concat(e.to_s + ',')
        end
        result.concat('
    <tr>
        <td><a href="https://jira/jira/browse/'+k.to_s+'">'+k.to_s+'</a> </td>'+"\n"+'        <td><a href="'+URL_PREFIX_MULTIPLE+s.chop+'">'+s.chop+'</a></td>
    </tr>')
        #if k =~ /QM-/
        #  result.concat(" "*2 + k.to_s + " "*12 + URL_PREFIX_MULTIPLE + s.chop + "\n")
        #elsif k=~ /INC/
        #  result.concat(" "*2 + k.to_s + " "*4 + URL_PREFIX_MULTIPLE + s.chop + "\n")
        #else
        #  result.concat(" "*2 + k.to_s + " "*9 + URL_PREFIX_MULTIPLE + s.chop + "\n")
        #end
      end
      $stdout.puts result_hash
      result.concat('
</table>')
      return result
    end

    def construct_sorted_by_labrun
      result = '
<h4>Bug List Sorted By LabrunID: </h4>
<table>'
      bugs.each_pair() do |k, v|
        if v.size != 0
          s = '    <td>'
          v.each do |e|
            s.concat('<a href="https://jira/jira/browse/'+e.to_s+'">'+e.to_s + '</a> ')
          end
          s.concat('</td>
    </tr>')
          result.concat('
    <tr>
        <td><a href='+URL_PREFIX_MULTIPLE+k.to_s+'">'+k.to_s+'</a></td>'+"\n"+s)
        end
      end
      result.concat('
</table>')
      $stdout.puts bugs
      return result
    end

    def construct_jira_bug_table
      # 统计出所有的bug，放入total_bugs中
      total_bugs = Array.new
      bugs.each_value do |e|
        total_bugs << e
      end

      if total_bugs.size != 0
        total_bugs.flatten!
        total_bugs.uniq!
      end

      # 以字符串的形式返回结果
      result = '
<h4>Total Bugs In Jira:</h4>
<table>
    <tr>
'
      s = ''
      total_bugs.each do |e|
        if e =~ /INC/
          s.concat("")
        else
          s.concat('        <td><a href="https://jira/jira/browse/'+e.to_s+'">'+e.to_s+'</a> </td>'+"\n")
        end
      end
      result.concat(s.chop + '
    </tr>
</table>')
      return result
    end

    def construct_hawaii_bug_table
      # 统计出所有的bug，放入total_bugs中
      total_bugs = Array.new
      bugs.each_value do |e|
        total_bugs << e
      end

      if total_bugs.size != 0
        total_bugs.flatten!
        total_bugs.uniq!
      end

      # 以字符串的形式返回结果
      result = '
<h4>Total Bugs In Hawaii:</h4>
<table>
    <tr>'
      s = ''
      total_bugs.each do |e|
        if e =~ /INC/
          s.concat(e.to_s + ',')
        else
          s.concat("")
        end
      end
      result.concat('
    </tr>
</table>')
      return result.concat(s.chop)
    end

    def construct_unfinished_labrun_table
      result = '
<h4>Unfinished Lanruns:</h4>
'
      s = ""
      if unfinished_labruns.size != 0
        unfinished_labruns.each() do |e|
          s.concat(e.to_s + ',')
        end
        result.concat('<td><a href="'+URL_PREFIX_MULTIPLE+s.chop+'">'+s.chop+'</a></td>'+"\n")
      end
      return result
    end

    def sort_bugs_by type
      # bugs = {"975398" => ["MAIN-65922","MAIN-62701"],"917801" => ["MAIN-62701"],"917798" => ["INC000000193570"],"915630" => ["MAIN-65295","QM-5410","QM-5392"] }
      result = ""
      case type
        when "labrun"
          result.concat("\n\n  Bug List Sorted By LabrunID: \n  LabrunID      Bugs\n" + "*"*42 + "\n")
          bugs.each_pair() do |k, v|
            if v.size != 0
              s = ''
              v.each do |e|
                s.concat(e.to_s + ',')
              end
              result.concat(" "*2 + k.to_s + " "*8 + s.chop + "\n")
            end
          end
          $stdout.puts bugs
          return result
        when "bug"
          # 统计出所有的bug，放入total_bugs中
          total_bugs = Array.new
          bugs.each_value do |e|
            total_bugs << e
          end

          if total_bugs.size != 0
            total_bugs.flatten!
            total_bugs.uniq!
          end

          # 以bug号作为key，有此bug的所有LabrunID组成的数组作为value
          result_hash = Hash.new
          total_bugs.each() do |b|
            ta = Array.new
            bugs.each_pair do |k,v|
              if v.find_index(b)
                ta << k
              end
            end
            result_hash[b] = ta
          end

          # 以字符串的形式返回结果
          result.concat("\n\n  Labrun List Sorted By Bug: \n  Bugs               LabrunID\n" + "*"*42 + "\n")
          result_hash.each_pair do |k, v|
            s = ''
            v.each do |e|
              s.concat(e.to_s + ',')
            end
            if k =~ /QM-/
              result.concat(" "*2 + k.to_s + " "*12 + URL_PREFIX_MULTIPLE + s.chop + "\n")
            elsif k=~ /INC/
              result.concat(" "*2 + k.to_s + " "*4 + URL_PREFIX_MULTIPLE + s.chop + "\n")
            else
              result.concat(" "*2 + k.to_s + " "*9 + URL_PREFIX_MULTIPLE + s.chop + "\n")
            end
          end
          $stdout.puts result_hash
           p result
          return result
        when "jira"
          # 统计出所有的bug，放入total_bugs中
          total_bugs = Array.new
          bugs.each_value do |e|
            total_bugs << e
          end

          if total_bugs.size != 0
            total_bugs.flatten!
            total_bugs.uniq!
          end

          # 以字符串的形式返回结果
          result.concat("\n\n  Total Bugs In Jira: \n" + "*"*42 + "\n")
          s = ''
          total_bugs.each do |e|
            if e =~ /INC/
              s.concat("")
            else
              s.concat(e.to_s + ',')
            end
          end
          return result.concat(" "*2 + s.chop)
        when "hawaii"
          # 统计出所有的bug，放入total_bugs中
          total_bugs = Array.new
          bugs.each_value do |e|
            total_bugs << e
          end

          if total_bugs.size != 0
            total_bugs.flatten!
            total_bugs.uniq!
          end

          # 以字符串的形式返回结果
          result.concat("\n\n  Total Bugs In Hawaii: \n" + "*"*42 + "\n")
          s = ''
          total_bugs.each do |e|
            if e =~ /INC/
              s.concat(e.to_s + ',')
            else
              s.concat("")
            end
          end
          return result.concat(" "*2 + s.chop)
        when "default"
          # 统计出所有的bug，放入total_bugs中
          total_bugs = Array.new
          bugs.each_value do |e|
            total_bugs << e
          end

          if total_bugs.size != 0
            total_bugs.flatten!
            total_bugs.uniq!
          end

          # 以字符串的形式返回结果
          result.concat("  Total Bugs: \n" + "*"*42 + "\n")
          s = ''
          total_bugs.each do |e|
            s.concat(e.to_s + ',')
          end
          return result.concat(" "*2 + s.chop)
        else
          raise "unsupported sort type."
      end
    end

    def get_unfinished_labrun_url
      result = ""
      result.concat("\n\n  Unfinished Lanruns:\n" + "*"*42 + "\n")
      s = ""
      if unfinished_labruns.size != 0
        unfinished_labruns.each() do |e|
          s.concat(e.to_s + ',')
        end
        result.concat(URL_PREFIX_MULTIPLE + s.chop)
      end
      return result
    end

  end

end