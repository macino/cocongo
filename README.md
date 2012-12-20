Cocongo
=======

Cocongo is a console based ruby 'any text file' generator. It generates files
based on variables given by prompt and than stored. It's useful for
generating configuration files for changing environments by changing only
the variables at one place.

---

* __Author:__ Tomáš Macik
* __Mail:__ <tomas.macik@gmail.com>
* __Homepage:__ <http://hg.bigant.eu/cococngo>

Quickstart
----------

There is an ease way how to make you changeable config files. Just create the files you need to customize and determine the values you heed to change.

Then create a ruby script using Cocongo. Here is an example:
_Let's say, we need to customize server name and database host and use it for cfg.ini_

`cfg.rb`

    require_relative('cocongo')
    c = Cocongo.new
    c
      .var('s', 'serverName', 'dvl/tst/prod', 'dvl')
      .var('d', 'dbHost', 'xdb for dvl', 'xdb')
      .tpl('cfg.ini.tpl', 'cfg.ini')
      .run

`cfg.ini.in`

    [server]
    name = <%=d('serverName')%>
    [db]
    user = 'usr'
    pass = '123'
    host = <%=d('dbName')%>

After running the `cfg.rb` script, you'll get a prompt for changing variables like this one bellow:

    $ ruby cfg.rb
    s: serverName []
    d: dbHost []
    ---
    . - save the properties, generate configs and exit
    ! - exit without saving
    cmd:

You need to just type in the shortcut for the variable and type the value of the current variable. After saving the variables, Cocongo will generate the `cfg.ini` file and store the variables in `vars.rb`.

The advantige of such configuration is that you dont need to save your config for each environment. You can have the templates of configs in your repository and the config file them selfs in `.gitignore` or `.hgignore` files.

Cocongo is able to generate multiple files from multiple templates.

Syntax
------

Adding vars to Cocongo

    var(shortcut, name, hint, default)

Adding templates

    tpl(templateFile, outputFile)

