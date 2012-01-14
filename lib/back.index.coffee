coffee = require 'coffee-script'
fs = require 'fs'
vm = require 'vm'

outputStr = []
output = (str)->
  outputStr.push str

tab     = 2
level   = 0
spaces  = ->
  num = level*tab
  text = []
  i = 0
  while i < num
    text.push ' '
    i++
  text.join ''

indent  = -> level++
outdent = -> level--

selfClosing = ['br', 'link', 'img']
printables = ['string', 'float', 'number', 'integer']

tag = (name)->
  (opts...)->
    output "#{spaces()}<#{name}"
    opts = opts.reverse()
    attrs = opts.pop()

    if typeof attrs is 'object'
      for attr, val of attrs
        output " #{attr}=\"#{val}\""
      arg = opts.pop()
    else
      arg = attrs
    output ">"
    if not arg and name in selfClosing then return output "\n"

    endString = yes
    while arg
      if typeof arg in printables
        output arg.toString()
        endString = yes
      else if typeof arg is 'function'
        output "\n"
        indent()
        arg()
        outdent()
        endString = no
      arg = opts.pop()
    output spaces() unless endString
    output "</#{name}>\n"

tags = {}

tagNames = [
  'html', 'head', 'body', 'link', 'p', 'script', 'div', 'h1', 'h2', 'h3', 'ul', 'ol', 'li'
]

for tagName in tagNames
  tags[tagName] = tag tagName

textyTags = [
  'span', 'b', 'i', 'em', 'strong', 'br', 'img'
]

text = (name)->
  (opts...)->
    op = []
    say = (str)-> op.push str
    say "<#{name}"
    opts = opts.reverse()
    attrs = opts.pop()

    if typeof attrs is 'object'
      for attr, val of attrs
        say " #{attr}=\"#{val}\""
      arg = opts.pop()
    else
      arg = attrs
    say ">"
    if not arg and name in selfClosing then return op.join ''

    endString = yes
    while arg
      if typeof arg in printables
        say arg.toString()
        endString = yes
      else if typeof arg is 'function'
        say "\n"
        indent()
        arg()
        outdent()
        endString = no
      arg = opts.pop()
    say spaces() unless endString
    say "</#{name}>"
    op.join ''


tags.print = (str)-> output spaces()+str+"\n"
for tagName in textyTags
  tags[tagName] = text tagName

module.exports =

  # render
  # Parse text as CSML
  render: (text)->
    outputStr = []
    text = coffee.compile text
    vm.runInNewContext text, tags
    outputStr.join ''
