
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
  def print()
    @items.each { |shortcut, item|
      puts "  " + shortcut + ": " + item['var'] + " [" + itemVal(shortcut) + "]"
    }
  end
  def itemVal(shortcut)
    item = item(shortcut)
    return item['value'] ? item['value'] : item['default'];
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
    File.new('vars.cfg', 'w'){|f|
      f.puts 'items = {'
      @items.each{}
    }
  end
end # }}}

class Cocongo # {{{
  @@sysCmds = ['.', '!']
  def initialize(m)
    @menu = m
  end
  def menu
    @menu.print()
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
    elsif cmd == '.' || cmd == '!'
      return cmd
    else
      puts 'Unknown command ' + cmd
      return ''
    end
  end
end # }}}

m = Menu.new()
m
 .add('a', 'varA', '', '')
 .add('b', 'varB', '', '')

y m.items.inspect

c= Cocongo.new(m)
#c.run()

