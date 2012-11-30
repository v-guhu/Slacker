#coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'tk'
require 'date'
require 'count'
require 'common_method'
require 'observer'

module BaseUI

  G_FONT          =  TkFont.new('times 10 bold')
  GT_FONT         =  TkFont.new('times 10')
  INPUT_PATH      =  '..\\files\\labruns.txt'
  OUTPUT_PATH     =  '..\\files\\output.txt'
  HTML_PATH       =  '..\\files\\bug_result.html'
  NOLABRUN_INFO   =  '请输入需要统计的labrun数据。'
  OPEN_FILE_INFO0 =  '您还没有开始此次bug的统计。
  是否打开上一次的结果？'
  OPEN_FILE_INFO1 =  '您还没有开始此次bug的统计。
是否导出上一次的bug的excel结果？'
  OPEN_ANLYSIS_INFO  =  '您还没有开始此次labrun的分析。
  是否打开上一次的分析结果？'

  INFO            = '
   Bug 统计小工具
     version 1.4
copyright@Phiso Hu'
  HELP            =  '统计bug有两种输入数据的方式：
1 手动输入： 点击‘手动输入’按钮即可在下面橘色的输入区输入你要统计的Labrun的URL。
2 从文件导入： 通过点击‘导入文件’按钮，您也可以导入保存在文件中的Labrun URL 数据。
最后点击‘开始统计’按钮， 耐心等待结果吧。统计愉快！'
  ISCOUNTING      =  '请稍后，正在统计中。。。'
  ISANLYSISING    =  '请稍后，正在分析中。。。'

  class UI
    attr_accessor :root
    attr_accessor :clock
    attr_accessor :date_label
    attr_accessor :clock_canvas

    def initialize
      create_ui
    end

    def create_ui
      @root = create_root
      create_menu
      create_canvas
      append_clock
      #loop
    end

    def create_root
      root = TkRoot.new do
        title 'Bug 统计小工具'
        minsize(650,500)
        maxsize(650,500)
        geometry('650x500')
        resizable(0,0)
        if Dir.pwd.to_s.encoding.to_s != 'GBK'
           iconbitmap "#{Dir.pwd}/images/crw.ico"
        end
      end
      return root
    end

    def append_clock
      @clock_canvas = TkCanvas.new(root) do
        #place('relx' => 1,'rely' => 1)
        place('relx' => 0.025,'rely' => 0.185, 'width' => '305', 'heigh' => '400')
      end
      @clock = Clock.new()
      clock_view = ClockView.new(@clock_canvas)
      clock.add_observer(clock_view)
    end

    def loop
      Tk.mainloop
    end

    def create_menu
      menu_bar       =  TkMenu.new(root)
      menu_help      =  TkMenu.new(menu_bar)
      menu_file      =  TkMenu.new(menu_bar)
      #menu_setting   =  TkMenu.new(menu_bar)

      menu_help_click = Proc.new do
        Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '关于Sales Taxes', 'parent' => root, 'message' => HELP)
      end
      menu_about_click = Proc.new do
        msg_box = Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '关于Sales Taxes', 'parent' => root, 'message' => INFO)
      end
      menu_exit_click = Proc.new{exit}
      menu_help.add('command', 'label' => "帮助", 'command' => menu_help_click, 'underline' => 0)
      menu_help.add('command', 'label' => "关于", 'command' => menu_about_click, 'underline' => 0)
      menu_file.add('command', 'label' => "关闭", 'command' => menu_exit_click, 'underline' => 0)
      menu_bar.add('cascade', 'menu'  => menu_file, 'label' => "文件")
      #menu_bar.add('cascade', 'menu'  => menu_setting, 'label' => "设置")
      menu_bar.add('cascade', 'menu'  => menu_help, 'label' => "帮助")
      root.menu(menu_bar)
    end

    def create_canvas
      welcome_frame = TkFrame.new(root) do
        pack('padx' => '2', 'pady' => '2', 'side' => 'top')
      end

      buttons_frame = TkFrame.new(root) do
        pack('padx' => '2', 'pady' => '2', 'side' => 'top', 'after' => welcome_frame, 'fill' => 'x')
      end

      result_frame = TkFrame.new(root) do
        pack('padx' => '2', 'pady' => '2', 'side' => 'top', 'after' => buttons_frame)
      end

      welcome_label = TkLabel.new(root) do
        text  '欢迎使用Bug 统计小工具'
        height 2
        pack('padx' => '2', 'pady' => '2', 'side' => 'left', 'in' => welcome_frame)
        font "arial 10 bold"
      end

      @date_label = TkLabel.new(root) do
        now  = Time.now
        date =  prefix_zero(now.hour) + ':' + prefix_zero(now.min) + ':' + prefix_zero(now.sec) + '  ' + prefix_zero(now.year) + '年' + prefix_zero(now.month) + '月' + prefix_zero(now.day) + '日'
        text   date
        height 2
        #background "#EDE223"
        foreground "#0F9EEE"
        place('relx' => 0.75,'rely' => 0.006)
        font "arial 9 bold"
      end

      manual_input_button = TkButton.new(root) do
        text  '手动输入'
        height 1
        font G_FONT
        pack('padx' => '12', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      input_form_file_button = TkButton.new(root) do
        text  '导入文件'
        height 1
        font G_FONT
        pack('padx' => '10', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      analysis_button = TkButton.new(root) do
        text  'Labrun分析'
        height 1
        font G_FONT
        pack('padx' => '10', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      analysis_result_button = TkButton.new(root) do
        text  '分析结果'
        height 1
        font G_FONT
        pack('padx' => '10', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      start_button = TkButton.new(root) do
        text  'Bug统计'
        height 1
        font G_FONT
        pack('padx' => '15', 'pady' => '5',  'side' => 'left',  'in' => buttons_frame)
      end

      html_button = TkButton.new(root) do
        text  'html结果'
        height 1
        font G_FONT
        pack('padx' => '10', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      output_to_excel_button = TkButton.new(root) do
        text  '表格导出'
        height 1
        font G_FONT
        pack('padx' => '15', 'pady' => '5', 'side' => 'right', 'in' => buttons_frame)
      end

      input_text = TkText.new(root) do
        width 50
        height 30
        state 'disabled'
        background  'black' #'#004488'
        font GT_FONT
        pack('padx' => '5', 'pady' => '5', 'side' => 'left', 'after' => start_button, 'in' => result_frame)
      end

      output_text = TkText.new(root) do
        width 50
        height 30
        state 'disabled'
        background 'gray'
        font GT_FONT
        pack( 'padx' => '5', 'pady' => '5', 'side' => 'left', 'after' => input_text, 'in' => result_frame)
      end

      welcome_label.bind('Enter') do
        welcome_label.configure('foreground' => 'orange')
      end

      welcome_label.bind('Leave') do
        welcome_label.configure('foreground' => 'black')
      end

      manual_input_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          input_text.configure('state' => 'normal', 'background' => 'orange')
          # move clock to invisible place
          @clock_canvas.place('relx' => 1,'rely' => 1)
        end
      end

      input_form_file_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          file_types = [ ['Text file', ['.txt', '.text']],
                         ['All files', ['*']]
          ]
          file_path = Tk.getOpenFile('filetypes' => file_types)
          if file_path.empty?
            return
          end
          input_text.configure('state' => 'normal', 'background' => 'orange')
          input_text.delete('1.0', 'end')
          File.open(file_path, 'r') do |file|
            while line = file.gets
              input_text.insert('end', line)
            end
          end
          input_text.configure('state' => 'disabled')
        end
      end

      analysis_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          if input_text.background == 'orange'
            output_text.configure('state' => 'normal', 'background' => 'orange')
            output_text.delete('1.0', 'end')
            # 写入要统计的labruns
            labruns = input_text.get('1.0', 'end')
            File.open("#{INPUT_PATH}", "w") do |file|
              file.puts labruns
            end

            # 开始统计
            # 由于不能在TKframe内部创建watir 的browser对象，目前只好采用这种方式。
            $threads["test only thread"] = Thread.new() do
              Thread.current[:name] = "test only thread"
              Thread.kill(Thread.current)
            end

            $threads["anlysis thread"] = Thread.new() do
              Thread.current[:name] = "anlysis thread"
              output_text.clear
              output_text.insert('end', "

I'm doing anlysis...

After anlysis finished, please click '分析结果' button to view the result.")
              anlysis_thread = system('ruby.exe anlysis_start.rb')
              if anlysis_thread
                output_text.clear
                $stdout.puts "finished labrun anlysis, all work well."
                output_text.insert('end', "

Finished labrun anlysis, all work well.

Please click '分析结果' button to view the result.")
                              #anlysis_thread = system('ruby.exe anlysis_start.rb')
              else
                output_text.clear
                $stderr.puts "an error occurred when anlysis labruns."
                output_text.insert('end', "

Sorry, an error occurred when anlysis labruns.

Please try again")
              end
              # 设置输出区状态
              output_text.configure('state' => 'disabled')
              Thread.kill(Thread.current)
            end
          else
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => NOLABRUN_INFO)
          end
        end
      end

      analysis_result_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          if output_text.background == 'orange'
            $threads["open anlysis result thread"] = Thread.new do
              system("open_anlysis_result_html.bat")
              #system('ruby.exe open_anlysis_result.rb')
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => OPEN_ANLYSIS_INFO)
            if r == 'yes'
              $threads["open anlysis result thread"] = Thread.new do
                system("open_anlysis_result_html.bat")
                #system('ruby.exe open_anlysis_result.rb')
                Thread.kill(Thread.current)
              end
            end
          end
        end
      end

      start_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          if input_text.background == 'orange'
            output_text.configure('state' => 'normal', 'background' => 'orange')
            output_text.delete('1.0', 'end')
            # 写入要统计的labruns
            labruns = input_text.get('1.0', 'end')
            File.open("#{INPUT_PATH}", "w") do |file|
              file.puts labruns
            end

            # 开始统计
            # 由于不能在TKframe内部创建watir 的browser对象，目前只好采用这种方式。
            $threads["test only thread"] = Thread.new() do
              Thread.current[:name] = "test only thread"
              Thread.kill(Thread.current)
            end

            $threads["count thread"] = Thread.new() do
              Thread.current[:name] = "count thread"
              output_text.insert('end', "

I'm counting bugs...

After finish please click 'html结果' to view result as html file, or click '表格导出' to export bugs from JIRA as excel file.")
              count_thread = system('ruby.exe count_start.rb')
              if count_thread
                $stdout.puts "Finished bug count, all work well."
                output_text.clear
                output_text.insert('end', "

Finished bug count, all work well.

Please click 'html结果' to view result as html file, or click '表格导出' to export bugs from JIRA as excel file.
The Labrun hyperlink(s) also have been added to excel for every bug.

")
              else
                $stderr.puts "An error occurred when count bugs."
                output_text.clear
                output_text.insert('end', "
Sorry, an error occurred when count bugs.

Please try again.

")
              end

              # 统计完毕将结果读出到UI界面
              data = IO.readlines("#{OUTPUT_PATH}")
              output_text.insert('end',data.join(""))

              # 设置输出区状态
              output_text.configure('state' => 'disabled')
              Thread.kill(Thread.current)
            end
          else
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => NOLABRUN_INFO)
          end
        end
      end

      output_to_excel_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          if output_text.background == 'orange'
            $threads["open result thread"] = Thread.new do
              # disable it for seldom use
              # system("notepad.exe #{OUTPUT_PATH}")
              system("ruby.exe export_excel_start.rb")
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => OPEN_FILE_INFO1)
            if r == 'yes'
              $threads["open result thread"] = Thread.new do
                # disable it for seldom use
                # system("notepad.exe #{OUTPUT_PATH}")
                system("ruby.exe export_excel_start.rb")
                Thread.kill(Thread.current)
              end
            end
          end
        end
      end

      html_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          if output_text.background == 'orange'
            $threads["open result thread"] = Thread.new do
              system("open_bug_result_html.bat")
              #system('ruby.exe open_bug_result.rb')
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => OPEN_FILE_INFO0)
            if r == 'yes'
              $threads["open result thread"] = Thread.new do
                system("open_bug_result_html.bat")
                #system('ruby.exe open_bug_result.rb')
                Thread.kill(Thread.current)
              end
            end
          end
        end
      end
    end

    def show_time
      now = Time.now
      date =  prefix_zero(now.hour) + ':' + prefix_zero(now.min) + ':' + prefix_zero(now.sec) + '  ' + prefix_zero(now.year) + '年' + prefix_zero(now.month) + '月' + prefix_zero(now.day) + '日'
      self.date_label.text = date
    end

    #下面时钟的两个类Clock 和 ClockView 源码来至开源中国： http://www.oschina.net/code/snippet_270852_9935
    #作者： KimboQi
    #修改： xausee

    class Clock
      #观察者模式
      include Observable

      def getPointAngle(time)
        #获取以y轴为线顺时针的角度,例如：3点钟则时针的角度为90度
        sec_angle = time.sec / 60.0 * 360
        min_angle = time.min / 60.0 * 360 + sec_angle / 360 / 60
        hour_angle = time.hour.divmod(12)[1] / 12.0 * 360 + min_angle / 360 * 30
        #转换成以xy轴的角度，例如3点钟，则时针的角度为0度，12点时针的角度为180度
        return [hour_angle, min_angle, sec_angle].collect do |x|
          x <= 90 ? 90 -x : 450 - x
        end
      end

      def run
        angles = self.getPointAngle(Time.now)
        changed()
        notify_observers(angles)
      end

    end

    class ClockView
      LENGTH_ARRAY = [40, 60, 80]

      def initialize(widget)
        @cur_sec_line = nil
        @cur_hour_line = nil
        @cur_min_line = nil
        @canvas = TkCanvas.new(widget, 'width' => '300', 'heigh' => '390')
        timg = TkPhotoImage.new('file' => File.join(File.dirname(__FILE__), '/images/', 'black.gif'))
        t = TkcImage.new(@canvas, 154, 180, 'image' => timg)
        @canvas.pack('side' => 'left', 'fill' => 'both')
      end

      def update(angles)
        coords = Array.new
        #将角度转换成在界面上的坐标
        angles.to_a().each_with_index do |mangle, index|
          cy = Math.sin(mangle / 180 * Math::PI) * LENGTH_ARRAY[index]
          cx = Math.cos(mangle / 180  * Math::PI) * LENGTH_ARRAY[index]
          cx = cx + 152
          cy = 165 - cy
          coords[index] = [cx, cy]
        end
        @cur_sec_line != nil and @cur_sec_line.delete()
        @cur_min_line != nil and @cur_min_line.delete()
        @cur_hour_line != nil and @cur_hour_line.delete()

        hline = TkcLine.new(@canvas, 152, 165, coords[0][0], coords[0][1], "width" => "3")
        mline = TkcLine.new(@canvas, 152, 165, coords[1][0], coords[1][1], "width" => "2")
        sline = TkcLine.new(@canvas, 152, 165, coords[2][0], coords[2][1], "width" => "1")

        [hline, mline, sline].map { |aline|
          aline.fill 'white'
        }

        @cur_sec_line = sline
        @cur_hour_line = hline
        @cur_min_line = mline
      end
    end

  end
end