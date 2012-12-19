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
  TEXT_CORLOR          =  '#FFC208'
  MAIN_BACKGROUND      =  '#003366'
  BUTTON_BACKGROUND    =  '#343635'
  MENU_BACKGROUND      =  '#003366'
  MENU_FOREGROUND      =  '#FFFFFF'
  INOUT_FOREGROUND     =  '#000000'
  INOUT_BACKGROUND     =  '#FFFFFF'
  BUTTON_RELY          =  0.085
  INOUT_TEXT_RELY      =  0.160
  INPUT_PATH           =  '..\\files\\labruns.txt'
  OUTPUT_PATH          =  '..\\files\\output.txt'
  HTML_PATH            =  '..\\files\\bug_result.html'
  NOLABRUN_INFO        =  'Please input the labrun link.'
  OPEN_FILE_INFO0      =  'No bug count start this time, Do you want to open last html result?'
  OPEN_FILE_INFO1      =  'No bug count start this time, Do you want to open last excel result？'
  OPEN_ANLYSIS_INFO    =  'No analysis start this time, Do you want to open last analysis result？'
  INFO                 =  '
   Bug Count Tool
     version 1.4
copyright@Phiso Hu'
  HELP                 =  'Usage：

1 Bug Count:
  (1) Click \'Input\' button, fill your labrun(s) into the following white text area
  (2) Click \'Start Count\' button to start bug count
  (3) Wait for count finish, click \'Html Result\' button to view html result
  (4) If you want to output bug as excel form, please click \'Excel Result\' button to start the thread then view the excel result

2 Labrun Analysis:
  (1) Click \'Input\' button, fill your labrun(s) into the following white text area
  (2) Click \'Analysis\' button to start analysis
  (3) Wait for analysis finish, click \'Analysis Result\'  button to view the result

If you want to come back to start UI, please click \'Reset\' button'
  ISCOUNTING           =  'Please wait, I\'m counting...'
  ISANLYSISING         =  'Please wait, I\'m analysising...'
  ISAUTORUNNING        =  'Please wait, I\'m monitoring labruns...'

  class UI
    attr_accessor :root
    attr_accessor :clock
    attr_accessor :date_label
    attr_accessor :clock_canvas
    attr_accessor :picture_canvas
    attr_accessor :monitor_time
    attr_accessor :subpage_load_time

    def initialize
      create_ui
      @subpage_load_time = "5"
      @monitor_time = "15"
    end

    def create_ui
      @root = create_root
      create_menu
      create_canvas
      append_clock
      append_picture
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

    def append_picture
      @picture_canvas = TkCanvas.new(root) do
        place('relx' => 0.500,'rely' => INOUT_TEXT_RELY, 'width' => '305', 'heigh' => '410')
      end
      timg = TkPhotoImage.new('file' => File.join(File.dirname(__FILE__), '/images/', 'sky.gif'))
      t = TkcImage.new(@picture_canvas, 154, 180, 'image' => timg)
    end

    def config_window root
      begin
        $win.destroy
      rescue
      end

      $win = TkToplevel.new(root) do
        title 'config your data'
        minsize(300,200)
        maxsize(300,200)
        background MAIN_BACKGROUND
        geometry('300x200')
      end

      monitor_time_label = TkLabel.new($win) do
        text  'Monitor Time:'
        height 2
        background MAIN_BACKGROUND
        foreground TEXT_CORLOR
      end

      subpage_load_time_label = TkLabel.new($win) do
        text  'Subpage Load Time:'
        height 2
        background MAIN_BACKGROUND
        foreground TEXT_CORLOR
      end

      min_label = TkLabel.new($win) do
        text  'Min'
        height 2
        background MAIN_BACKGROUND
        foreground TEXT_CORLOR
      end

      sec_label = TkLabel.new($win) do
        text  'Sec'
        background MAIN_BACKGROUND
        foreground TEXT_CORLOR
      end

      apply_button = TkButton.new($win) do
        text 'Apply'
        background MAIN_BACKGROUND
        foreground TEXT_CORLOR
      end

      monitor_time_entry = TkEntry.new($win)
      subpage_load_entry = TkEntry.new($win)

      var_monitor_time = TkVariable.new
      var_subpage_load_time = TkVariable.new

      monitor_time_entry.textvariable = var_monitor_time
      subpage_load_entry.textvariable = var_subpage_load_time

      var_monitor_time.value = @monitor_time
      var_subpage_load_time.value = @subpage_load_time

      monitor_time_label.place('x' => 10, 'y' => 10)
      subpage_load_time_label.place('x' => 10, 'y' => 40)
      monitor_time_entry.place('height' => 25, 'width' => 100, 'x' => 140, 'y' => 10)
      subpage_load_entry.place('height' => 25, 'width'  => 100, 'x' => 140, 'y' => 40)
      min_label.place('x' => 250, 'y' => 10)
      sec_label.place('x' => 250, 'y' => 40)
      apply_button.place('height' => 25, 'width' => 150, 'x' => 100, 'y' => 80)

      @monitor_time      = var_monitor_time.value
      @subpage_load_time = var_subpage_load_time.value


      apply_button.comman  = Proc.new do
        @monitor_time      = var_monitor_time.value
        @subpage_load_time = var_subpage_load_time.value
        $win.destroy
      end

      return true
    end

    def loop
      Tk.mainloop
    end

    def create_menu
      menu_bar       =  TkMenu.new(root) do
        background MENU_BACKGROUND
        foreground MENU_FOREGROUND
        font       BUTTON_FONT
      end

      menu_help      =  TkMenu.new(menu_bar) do
        background MENU_BACKGROUND
        foreground MENU_FOREGROUND
        font       BUTTON_FONT
      end

      menu_file      =  TkMenu.new(menu_bar) do
        background MENU_BACKGROUND
        foreground MENU_FOREGROUND
        font       BUTTON_FONT
      end

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

      input_button = TkButton.new(root) do
        text  'Input'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.025,'rely' => BUTTON_RELY)
      end

      analysis_button = TkButton.new(root) do
        text  'Analysis'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.150,'rely' => BUTTON_RELY)
      end

      analysis_result_button = TkButton.new(root) do
        text  'Analysis Result'
        height 1
        width 15
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.275,'rely' => BUTTON_RELY)
      end

      start_button = TkButton.new(root) do
        text  'Start Count'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.455,'rely' => BUTTON_RELY)
      end

      html_button = TkButton.new(root) do
        text  'Html Result'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.580,'rely' => BUTTON_RELY)
      end

      output_to_excel_button = TkButton.new(root) do
        text  'Excel Result'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.705,'rely' => BUTTON_RELY)
      end

      reset_button = TkButton.new(root) do
        text  'Reset'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.845,'rely' => BUTTON_RELY)
      end

      autorun_button = TkButton.new(root) do
        text  'Autorun'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.025,'rely' => 0.01)
      end

      config_button = TkButton.new(root) do
        text  'Config'
        height 1
        width 10
        background BUTTON_BACKGROUND
        foreground TEXT_CORLOR
        font BUTTON_FONT
        place('relx' => 0.5,'rely' => 0.01)
      end

      input_text = TkText.new(root) do
        width 50
        height 27
        state 'disabled'
        foreground INOUT_FOREGROUND
        background  'black'
        font TEXT_FONT
        place('relx' => 0.025,'rely' => INOUT_TEXT_RELY)
      end

      output_text = TkText.new(root) do
        width 50
        height 27
        state 'disabled'
        foreground INOUT_FOREGROUND
        background 'black'
        font TEXT_FONT
        place('relx' => 0.500,'rely' => INOUT_TEXT_RELY)
      end

      welcome_label.bind('Enter') do
        welcome_label.configure('foreground' => '#0F9EEE')
      end

      welcome_label.bind('Leave') do
        welcome_label.configure('foreground' => TEXT_CORLOR)
      end

      input_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
            (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
            (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

           if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
           end

           if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
           end

           if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
           end
        else
          input_text.delete('1.0', 'end')
          input_text.configure('state' => 'normal', 'background' => INOUT_BACKGROUND)
          # move clock to invisible place
          @clock_canvas.place('relx' => 1,'rely' => 1)
        end
      end

      analysis_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
            (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
            (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

           if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
           end

           if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
           end

           if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
          end
        else
          if input_text.background == INOUT_BACKGROUND
            output_text.configure('state' => 'normal', 'background' => INOUT_BACKGROUND)
            output_text.delete('1.0', 'end')
            # Input labruns
            labruns = input_text.get('1.0', 'end')
            File.open("#{INPUT_PATH}", "w") do |file|
              file.puts labruns
            end

            # Start count
            # 由于不能在TKframe内部创建watir 的browser对象，目前只好采用这种方式。
            $threads["test only thread"] = Thread.new() do
              Thread.current[:name] = "test only thread"
              Thread.kill(Thread.current)
            end

            $threads["anlysis thread"] = Thread.new() do
              Thread.current[:name] = "anlysis thread"
              # Move picture canvas to hide it
              @picture_canvas.place('relx' => 1,'rely' => 1)
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
                Tk.messageBox('type' => "ok", 'icon' => "error", 'title' => 'Info', 'parent' => root, 'message' => 'An error occurred when anlysis labruns')
              end
              # configure the state of output text area
              output_text.configure('state' => 'disabled')
              Thread.kill(Thread.current)
            end
          else
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => NOLABRUN_INFO)
          end
        end
      end

      analysis_result_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
            (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
            (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

           if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
           end

           if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
           end

           if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
           end
        else
          if output_text.background == INOUT_BACKGROUND
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
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
            (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
            (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

           if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
           end

           if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
           end

           if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
           end
        else
          if input_text.background == INOUT_BACKGROUND
            output_text.configure('state' => 'normal', 'background' => INOUT_BACKGROUND)
            output_text.delete('1.0', 'end')
            # Input labruns
            labruns = input_text.get('1.0', 'end')
            File.open("#{INPUT_PATH}", "w") do |file|
              file.puts labruns
            end

            # Start count
            # 由于不能在TKframe内部创建watir 的browser对象，目前只好采用这种方式。
            $threads["test only thread"] = Thread.new() do
              Thread.current[:name] = "test only thread"
              Thread.kill(Thread.current)
            end

            $threads["count thread"] = Thread.new() do
              Thread.current[:name] = "count thread"
              # Move picture canvas to hide it
              @picture_canvas.place('relx' => 1,'rely' => 1)
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
                Tk.messageBox('type' => "ok", 'icon' => "error", 'title' => 'Info', 'parent' => root, 'message' => 'An error occurred when count bugs.')
              end

              # Count finish and write result to UI
              data = IO.readlines("#{OUTPUT_PATH}")
              output_text.insert('end',data.join(""))

              # Config output text area state
              output_text.configure('state' => 'disabled')
              Thread.kill(Thread.current)
            end
          else
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => NOLABRUN_INFO)
          end
        end
      end

      output_to_excel_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
            (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
            (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

           if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
           end

           if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
           end

           if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
           end
        else
          if output_text.background == INOUT_BACKGROUND
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

      config_button.comman = Proc.new do
        config_window root
      end

      reset_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
            (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
            (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
          end

          if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
            Thread.kill($threads["autorun thread"])
            #Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
            input_text.delete('1.0', 'end')
            input_text.configure('state' => 'disabled', 'background' => 'black')
            output_text.configure('state' => 'disabled', 'background' => 'black')
            @clock_canvas.place('relx' => 0.025, 'rely' => INOUT_TEXT_RELY)
            @picture_canvas.place('relx' => 0.500, 'rely' => INOUT_TEXT_RELY)
          end

        else
          input_text.delete('1.0', 'end')
          input_text.configure('state' => 'disabled', 'background' => 'black')
          output_text.configure('state' => 'disabled', 'background' => 'black')
          @clock_canvas.place('relx' => 0.025, 'rely' => INOUT_TEXT_RELY)
          @picture_canvas.place('relx' => 0.500, 'rely' => INOUT_TEXT_RELY)
        end
      end

      html_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
            (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
            (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

           if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
           end

           if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
           end

           if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
             Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
           end
        else
          if output_text.background == INOUT_BACKGROUND
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

      autorun_button.comman = Proc.new do
        if ((!$threads["count thread"].nil? && $threads["count thread"].alive?) ||
           (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?) ||
           (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?))

          if (!$threads["count thread"].nil? && $threads["count thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISCOUNTING)
          end

          if (!$threads["anlysis thread"].nil? && $threads["anlysis thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISANLYSISING)
          end

          if (!$threads["autorun thread"].nil? && $threads["autorun thread"].alive?)
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => ISAUTORUNNING)
          end

        else
          if input_text.background == INOUT_BACKGROUND
            output_text.configure('state' => 'normal', 'background' => INOUT_BACKGROUND)
            output_text.delete('1.0', 'end')
            # Input labruns
            labruns = input_text.get('1.0', 'end')
            File.open("#{INPUT_PATH}", "w") do |file|
              file.puts labruns
            end

            $threads["autorun thread"] = Thread.new() do
              Thread.current[:name] = "autorun thread"
              # Move picture canvas to hide it
              @picture_canvas.place('relx' => 1,'rely' => 1)
              output_text.clear
              output_text.insert('end', "

I'm monitoring labrun...

If you want to stop monitor, please hit 'Reset' button.")
              monitor_thread = system("ruby.exe auto_run_labrun_start.rb #{@monitor_time}, #{@subpage_load_time}")
              output_text.configure('state' => 'disabled')
              Thread.kill(Thread.current)
            end
          else
            Tk.messageBox('type' => "ok", 'icon' => "info", 'title' => 'Info', 'parent' => root, 'message' => NOLABRUN_INFO)
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