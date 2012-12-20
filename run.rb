require_relative 'cocongo'

c= Cocongo.new
c
  .var('a', 'varA', '', '')
  .var('b', 'varB', 'num', 0)
  .tpl('test.in', 'test.out')
  .run()

