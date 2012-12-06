#coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'tk'
require 'date'
require 'count'
require 'common_method'
require 'observer'

module BaseUI

  BUTTON_FONT          =  TkFont.new('arial 8 bold')
  TEXT_FONT            =  TkFont.new('times 10')
  TEXT_CORLOR          =  '#003366'
  MAIN_BACKGROUND      =  '#FDEFB0'
  BUTTON_BACKGROUND    =  '#B5E84F'
  MENU_BACKGROUND      =  '#003366'
  MENU_FOREGROUND      =  '#FFFFFF'
  BUTTON_RELY        =  0.085
  INOUT_TEXT_RELY    =  0.160
  INPUT_PATH           =  '..\\files\\labruns.txt'
  OUTPUT_PATH          =  '..\\files\\output.txt'
  HTML_PATH            =  '..\\files\\bug_result.html'
  NOLABRUN_INFO        =  'Please input the labrun link.'
  OPEN_FILE_INFO0      =  'No bug count start this time, Do you want to open last html result?'
  OPEN_FILE_INFO1      =  'No bug count start this time, Do you want to open last excel result？'
  OPEN_ANLYSIS_INFO    =  'No analysis start this time, Do you want to open last analysis result？'
  INFO                 = '
   Bug Count Tool
     version 1.4
copyright@Phiso Hu'
  HELP                 =  'Usage：

1 Bug Count:
  (1) Click \'Input\' button, fill your labrun(s) into the following orange text area
  (2) Click \'Start Count\' button to start bug count
  (3) Wait for count finish, click \'Html Result\' button to view html result
  (4) If you want to output bug as excel form, please click \'Excel Result\' button to start the thread then view the excel result

2 Labrun Analysis:
  (1) Click \'Input\' button, fill your labrun(s) into the following orange text area
  (2) Click \'Analysis\' button to start analysis
  (3) Wait for analysis finish, click \'Analysis Result\'  button to view the result'
  ISCOUNTING           =  'Please wait, I\'m counting...'
  ISANLYSISING         =  'Please wait, I\'m analysising...'

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
        title 'Bug Count Tool'
        minsize(650,500)
        maxsize(650,500)
        background MAIN_BACKGROUND
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
        place('relx' => 0.025,'rely' => INOUT_TEXT_RELY, 'width' => '305', 'heigh' => '410')
      end
      @clock = Clock.new()
      clock_view = ClockView.new(@clock_canvas)
      clock.add_observer(clock_view)
    end

    def loop
      Tk.mainloop
    end

    def create_menu
      menu_bar       =  TkMenu.new(root) do
        background MENU_BACKGROUND
        foreground MENU_FOREGROUND
      end
      menu_help      =  TkMenu.new(menu_bar) do
        background MENU_BACKGROUND
        foreground MENU_FOREGROUND
      end

      menu_file      =  TkMenu.new(menu_bar) do
        background MENU_BACKGROUND
        foreground MENU_FOREGROUND
      end
      #menu_setting   =  TkMenu.new(menu_bar)

      menu_help_click = Proc.new do
        Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Help', 'parent' => root, 'message' => HELP)
      end
      menu_about_click = Proc.new do
        msg_box = Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'About Bug Count Tool', 'parent' => root, 'message' => INFO)
      end
      menu_exit_click = Proc.new{exit}
      menu_help.add('command', 'label' => "Help", 'command' => menu_help_click, 'underline' => 0)
      menu_help.add('command', 'label' => "About", 'command' => menu_about_click, 'underline' => 0)
      menu_file.add('command', 'label' => "Close", 'command' => menu_exit_click, 'underline' => 0)
      menu_bar.add('cascade', 'menu'  => menu_file, 'label' => "File")
      #menu_bar.add('cascade', 'menu'  => menu_setting, 'label' => "设置")
      menu_bar.add('cascade', 'menu'  => menu_help, 'label' => "Help")
      root.menu(menu_bar)
    end

    def create_canvas
      welcome_frame = TkFrame.new(root) do
        background MAIN_BACKGROUND
        pack('padx' => '2', 'pady' => '2', 'side' => 'top')
      end

      buttons_frame = TkFrame.new(root) do
        background MAIN_BACKGROUND
        pack('padx' => '2', 'pady' => '2', 'side' => 'top', 'after' => welcome_frame, 'fill' => 'x')
      end

      result_frame = TkFrame.new(root) do
        background MAIN_BACKGROUND
        pack('padx' => '2', 'pady' => '2', 'side' => 'top', 'after' => buttons_frame)
      end

      welcome_label = TkLabel.new(root) do
        text  'Thank You For Using Bug Count Tool'
        height 2
        background MAIN_BACKGROUND
        foreground TEXT_CORLOR
        pack('padx' => '2', 'pady' => '2', 'side' => 'left', 'in' => welcome_frame)
        font "arial 10 bold"
      end

      @date_label = TkLabel.new(root) do
        now  = Time.now
        date =  prefix_zero(now.hour) + ':' + prefix_zero(now.min) + ':' + prefix_zero(now.sec) + '  ' + prefix_zero(now.year) + '年' + prefix_zero(now.month) + '月' + prefix_zero(now.day) + '日'
        text   date
        height 2
        background MAIN_BACKGROUND
        foreground TEXT_CORLOR
        place('relx' => 0.8,'rely' => 0.006)
        font "arial 9 bold"
      end

      manual_input_button = TkButton.new(root) do
        text  'Input'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.025,'rely' => BUTTON_RELY)
        #pack('padx' => '12', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      #input_form_file_button = TkButton.new(root) do
      #  text  'Input File'
      #  height 1
      #  font BUTTON_FONT
      #  pack('padx' => '10', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      #end

      analysis_button = TkButton.new(root) do
        text  'Analysis'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.150,'rely' => BUTTON_RELY)
        #pack('padx' => '5', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      analysis_result_button = TkButton.new(root) do
        text  'Analysis Result'
        height 1
        width 15
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.275,'rely' => BUTTON_RELY)
        #pack('padx' => '5', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      start_button = TkButton.new(root) do
        text  'Start Count'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.455,'rely' => BUTTON_RELY)
        #pack('padx' => '15', 'pady' => '5',  'side' => 'left',  'in' => buttons_frame)
      end

      html_button = TkButton.new(root) do
        text  'Html Result'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.580,'rely' => BUTTON_RELY)
        #pack('padx' => '5', 'pady' => '5', 'side' => 'left', 'in' => buttons_frame)
      end

      output_to_excel_button = TkButton.new(root) do
        text  'Excel Result'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.705,'rely' => BUTTON_RELY)
        #pack('padx' => '15', 'pady' => '5', 'side' => 'right', 'in' => buttons_frame)
      end

      input_text = TkText.new(root) do
        width 50
        height 27
        state 'disabled'
        background  'black'
        font TEXT_FONT
        place('relx' => 0.025,'rely' => INOUT_TEXT_RELY)
        #pack('padx' => '5', 'pady' => '5', 'side' => 'left', 'after' => start_button, 'in' => result_frame)
      end

      output_text = TkText.new(root) do
        width 50
        height 27
        state 'disabled'
        background 'black'
        font TEXT_FONT
        place('relx' => 0.500,'rely' => INOUT_TEXT_RELY)
        #pack( 'padx' => '5', 'pady' => '5', 'side' => 'left', 'after' => input_text, 'in' => result_frame)
      end

      welcome_label.bind('Enter') do
        welcome_label.configure('foreground' => '#0F9EEE')
      end

      welcome_label.bind('Leave') do
        welcome_label.configure('foreground' => TEXT_CORLOR)
      end

      manual_input_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          input_text.configure('state' => 'normal', 'background' => 'orange')
          # move clock to invisible place
          @clock_canvas.place('relx' => 1,'rely' => 1)
        end
      end

      #input_form_file_button.comman = Proc.new do
      #  if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
      #    if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
      #      Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
      #    end
      #
      #    if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
      #      Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
      #    end
      #  else
      #    file_types = [ ['Text file', ['.txt', '.text']],
      #                   ['All files', ['*']]
      #    ]
      #    file_path = Tk.getOpenFile('filetypes' => file_types)
      #    if file_path.empty?
      #      return
      #    end
      #    input_text.configure('state' => 'normal', 'background' => 'orange')
      #    input_text.delete('1.0', 'end')
      #    File.open(file_path, 'r') do |file|
      #      while line = file.gets
      #        input_text.insert('end', line)
      #      end
      #    end
      #    input_text.configure('state' => 'disabled')
      #  end
      #end

      analysis_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
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

After anlysis finished, please click 'Analysis Result' button to view the result.")
              anlysis_thread = system('ruby.exe anlysis_start.rb')
              if anlysis_thread
                output_text.clear
                $stdout.puts "finished labrun anlysis, all work well."
                output_text.insert('end', "

Finished labrun anlysis, all work well.

Please click 'Analysis Result' button to view the result.")
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
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => NOLABRUN_INFO)
          end
        end
      end

      analysis_result_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          if output_text.background == 'orange'
            $threads["open anlysis result thread"] = Thread.new do
              system("open_anlysis_result_html.bat")
              #system('ruby.exe open_anlysis_result.rb')
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => OPEN_ANLYSIS_INFO)
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
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
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

After finish please click 'Html Result' to view result as html file, or click 'Excel Result' to export bugs from JIRA as excel file.")
              count_thread = system('ruby.exe count_start.rb')
              if count_thread
                $stdout.puts "Finished bug count, all work well."
                output_text.clear
                output_text.insert('end', "

Finished bug count, all work well.

Please click 'html结果' to view result as html file, or click 'Excel Result' to export bugs from JIRA as excel file.
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
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => NOLABRUN_INFO)
          end
        end
      end

      output_to_excel_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) || (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?))
          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
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
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => OPEN_FILE_INFO1)
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
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
          end
        else
          if output_text.background == 'orange'
            $threads["open result thread"] = Thread.new do
              system("open_bug_result_html.bat")
              #system('ruby.exe open_bug_result.rb')
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => OPEN_FILE_INFO0)
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
      date =  prefix_zero(now.hour) + ':' + prefix_zero(now.min) + ':' + prefix_zero(now.sec) + '  ' + prefix_zero(now.month) + '.' + prefix_zero(now.day) + '.' + prefix_zero(now.year)
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
        @canvas = TkCanvas.new(widget, 'width' => '300', 'heigh' => '410')
        timg = TkPhotoImage.new('file' => File.join(File.dirname(__FILE__), '/images/', 'black.gif'))
        t = TkcImage.new(@canvas, 154, 180, 'image' => timg)
        #@canvas.place('relx' => 0.0,'rely' => 0)
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