require 'erb'

HELP = <<HELP_STR
  ---
  . - save the properties, generate configs and exits
  ! - exit without saving
HELP_STR

class Menu # {{{
  def initialize()
    @items = {}
  end
  def add(shortcut, var, hint, default)
    @items[shortcut] = {
      'var' => var,
      'hint' => hint,
      'default' => default,
      'value' => '',
    }
    return self
  end
  def print
    @items.each { |shortcut, item|
      puts "  " + shortcut + ": " + item['var'] + " [" + itemVal(shortcut) + "]"
    }
  end
  def itemVal(shortcut)
    item = item(shortcut)
    return item['value'] || item['default'];
  end
  def item(shortcut)
    return @items[shortcut]
  end
  def items
    return @items
  end
  def setVal(shortcut, val)
    @items[shortcut]['value'] = val
  end
  def hasShortcut?(shortcut)
    return @items.key?(shortcut)
  end
  def prompt(shortcut)
    item = item(shortcut)
    $stdout.print(
      item['var'] + ' (' + item['hint'] + ')' + '[' + itemVal(shortcut) + ']:'
    )
    return gets
  end
  def saveVars
    File.open('vars.rb', 'w'){|f|
      f.puts 'module Vars'
      @items.each {|shortcut, item|
        val = itemVal(shortcut)
        val = val.gsub(/"/,'\"')
        f.puts '  ' + item['var'].upcase + '="' + val + '"'
      }
      f.puts "end\n"
    }
  end
  def loadVars
    if File.exists?('vars.rb')
      require_relative 'vars.rb'
      @items.each { |shortcut, item|
        c = item['var'].upcase.to_sym
        if Vars.const_defined?(c)
          @items[shortcut]['value'] = Vars.const_get(c)
        end
      }
    end
  end
end # }}}

class Generator # {{{
  def initialize
    @tpls = Array.new
    @data = Hash.new
  end
  def add (infile, outfile)
    @tpls.push({
      'in' => infile,
      'out' => outfile,
    })
    return self
  end
  def addData (data)
    @data = @data + data
    return self
  end
  def d (key)
   return @data[key]
  end
  def dataFromMenu (menu)
    menu.items.each { |shortcut, item|
      @data[item['var']] = menu.itemVal(shortcut)
    }
    return self
  end
  def generate
    @tpls.each { |tpl|
      out = ERB.new(File.read(tpl['in']))
      File.write(tpl['out'], out.result(getBinding).gsub(/\r\n/, "\n"))
    }
  end
  def getBinding
    return binding
  end
end # }}}

class Cocongo # {{{
  def initialize
    @menu = Menu.new
    @generator = Generator.new
  end
  def var (shortcut, var, hint, default)
    @menu.add(shortcut, var, hint, default)
    return self
  end
  def tpl (infile, outfile)
    @generator.add(infile, outfile)
    return self
  end
  def menu
    @menu.print
    puts HELP
  end
  def menuPrompt
    print('cmd:')
    return gets
  end
  def varPrompt(shortcut)
    return @menu.prompt(shortcut)
  end
  def run
    @menu.loadVars
    cmd= ''
    quit = false
    while !quit
      if cmd == ''
        menu()
        cmd = handleCmd(menuPrompt().strip())
      else
        @menu.setVal(cmd, varPrompt(cmd).strip())
        cmd = ''
      end
      quit = quit?(cmd)
    end
  end
  def quit?(cmd)
    return cmd == '.' || cmd == '!'
  end
  def handleCmd(cmd)
    if @menu.hasShortcut?(cmd)
      return cmd
    elsif cmd == '.'
      @menu.saveVars
      @generator.dataFromMenu(@menu).generate
      return cmd
    elsif cmd == '!'
      return cmd
    else
      puts 'Unknown command ' + cmd
      return ''
    end
  end
end # }}}

c= Cocongo.new
c
  .var('a', 'varA', '', '')
  .var('b', 'varB', 'num', 0)
  .tpl('test.in', 'test.out')
  .run()

