#coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'tk'
require 'count'

module BaseUI

  G_FONT          =  TkFont.new('times 10 bold')
  GT_FONT         =  TkFont.new('times 10')
  INPUT_PATH      =  '..\\files\\labruns.txt'
  OUTPUT_PATH     =  '..\\files\\output.txt'
  HTML_PATH       =  '..\\files\\bug_result.html'
  NOLABRUN_INFO   =  '请输入需要统计的labrun数据。'
  OPEN_FILE_INFO  =  '您还没有开始此次bug的统计。
是否打开上一次的统计结果？'
  OPEN_ANLYSIS_INFO  =  '您还没有开始此次labrun的分析。
  是否打开上一次的分析结果？'

  INFO            = '
   Bug 统计小工具
     version 1.0
copyright@Phiso Hu'
  HELP            =  '统计bug有两种输入数据的方式：
1 手动输入： 点击‘手动输入’按钮即可在下面橘色的输入区输入你要统计的Labrun的URL。
2 从文件导入： 通过点击‘导入文件’按钮，您也可以导入保存在文件中的Labrun URL 数据。
最后点击‘开始统计’按钮， 耐心等待结果吧。统计愉快！'
  ISCOUNTING      =  '请稍后，正在统计中。。。'
  ISANLYSISING    =  '请稍后，正在分析中。。。'

  class UI
    attr_accessor :root

    def initialize
      create_ui
    end

    def create_ui
      @root = create_root
      create_menu
      create_canvas
      loop
    end

    def create_root
      root = TkRoot.new do
        title 'Bug 统计小工具'
        minsize(650,500)
        maxsize(650,500)
        geometry('650x500')
        resizable(0,0)
        #iconbitmap "crw.ico"
      end
      return root
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

      output_to_file_button = TkButton.new(root) do
        text  '文本结果'
        height 1
        font G_FONT
        pack('padx' => '15', 'pady' => '5', 'side' => 'right', 'in' => buttons_frame)
      end

      input_text = TkText.new(root) do
        width 50
        height 30
        state 'disabled'
        background 'gray'
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
              anlysis_thread = system('ruby.exe anlysis_start.rb')
              if anlysis_thread
                $stdout.puts "finished labrun anlysis, all work well."
              else
                $stderr.puts "an error occurred when anlysis labruns."
              end

              # 统计完毕将结果读出到UI界面
              output_text.insert('end', 'Labrun anlysis finished, please click anlysis result button to view.')

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
              system('open_anlysis_result_html.bat')
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => OPEN_ANLYSIS_INFO)
            if r == 'yes'
              $threads["open anlysis result thread"] = Thread.new do
                system('open_anlysis_result_html.bat')
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
              count_thread = system('ruby.exe count_start.rb')
              if count_thread
                $stdout.puts "finished bug count, all work well."
              else
                $stderr.puts "an error occurred when count bugs."
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

      output_to_file_button.comman = Proc.new do
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
              system("notepad.exe #{OUTPUT_PATH}")
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => OPEN_FILE_INFO)
            if r == 'yes'
              $threads["open result thread"] = Thread.new do
                system("notepad.exe #{OUTPUT_PATH}")
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
              system('open_bug_result_html.bat')
              Thread.kill(Thread.current)
            end
          else
            r = Tk.messageBox('type' => "yesno", 'icon' => "info", 'title' => '提示', 'parent' => root, 'message' => OPEN_FILE_INFO)
            if r == 'yes'
              $threads["open result thread"] = Thread.new do
                system('open_bug_result_html.bat')
                Thread.kill(Thread.current)
              end
            end
          end
        end
      end

    end
  end
end