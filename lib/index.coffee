coffee = require 'coffee-script'
fs     = require 'fs'
vm     = require 'vm'
_      = require 'underscore'

# Tag descriptions
blockTags   = ['html', 'head', 'body', 'link', 'p', 'script', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li']
inlineTags  = ['span', 'b', 'i', 'em', 'strong', 'br', 'img']
selfClosing = ['br', 'link', 'img']

# Which types can be coerced to a string?
printables  = ['string', 'float', 'number', 'integer']

###
@name Parser
@description Parser class.  Exposes methods to parse text written in
  CSML into HTML
@class
###
class Parser

  ###
  @name constructor
  @constructor
  @function
  @memberOf Parser.prototype
  ###
  constructor: ->
    @tab        = 2
    @_level     = 0
    @_condensed = false
    @_createTags()

  ###
  @description Given a string of CSML text, returns a string the rendered HTML
  @name render
  @public
  @function
  @memberOf Parser.prototype

  @param {String} text String of CSML
  @param {Object} context Context for the rendered CSML.  Used to put variables
    into your template
  @return {String} Rendered HTML
  ###
  render: (text, context={})->
    @outputStr = []
    code = ["with (tags) {", coffee.compile(text), "}"].join "\n"
    vm.runInNewContext code, @_sandbox context
    @outputStr.join ''

  ###
  @description Wrapper for render, with no indentations or line breaks
  @name condense
  @public
  @function
  @memberOf Parser.prototype

  @param {String} text String of CSML
  @param {Object} context Context for the rendered CSML.  Used to put variables
    into your template
  @return {String} Rendered HTML
  ###
  condense: (text, context)->
    @_condensed = true
    output = @render text, context
    @_condensed = false
    output

  ###
  @description Creates a sanbox object for the template vm
  @name _sandbox
  @private
  @function
  @memberOf Parser.prototype

  @param {Object} context Context of this sandbox
  @return {Object} VM sandbox
  ###
  _sandbox: (context)->
    tags: @tags,
    __: (opts...)=>
      name = opts.shift()
      @_defineBlockTags [name]
      @tags[name].apply @, opts

    context: context
    defineTags: (tagNames...)=> @_defineBlockTags tagNames

  _defineInlineTags: (tagNames)->
    for name in tagNames
      @tags[name] = @_tagGenerator name

  _defineBlockTags: (tagNames)->
    print = (str)=> @outputStr.push str
    for name in tagNames
      @tags[name] = @_tagGenerator name, print

  ###
  @description Returns a string of spaces to properly indent code at the
    given indentation level
  @name _spaces
  @private
  @function
  @memberOf Parser.prototype
  @return {String} String of spaces
  ###
  _spaces: ->
    return '' unless @_level and @tab and not @_condensed
    num = @_level*@tab
    (' ' for x in [1..num]).join ''

  ###
  @description Returns a new line character, if we are not in condensed mode
  @name _newLine
  @private
  @function
  @memberOf Parser.prototype
  ###
  _newLine: -> return "\n" unless @_condensed

  ###
  @description Increases indentation level
  @name _indent
  @private
  @function
  @memberOf Parser.prototype
  ###
  _indent:  -> @_level++

  ###
  @description Decreases indentation level
  @name _outdent
  @private
  @function
  @memberOf Parser.prototype
  ###
  _outdent: -> @_level--

  ###
  @description Generate tag functions for every block level tag and every
    inline tag
  @name _createTags
  @private
  @function
  @memberOf Parser.prototype
  ###
  _createTags: ->
    @tags = {}
    @_defineBlockTags blockTags
    @_defineInlineTags inlineTags

  ###
  @description Creates a function that will handle outputing a given tag
    If its given the renderer method, it will use that to output it,
    otherwise it will just return the data as a string.

    This creates the one caveat of the way this language works: inline
    elements must be used inside of block level elements.  This is because
    the block level elements output their contents, while the inline elements
    simply return their contents so that a parent block element can output it.
  @name _tagGenerator
  @private
  @function
  @memberOf Parser.prototype
  ###
  _tagGenerator: (name, renderer=false)->

    (opts...)=>
      scoped = no
      inner = []

      # If a renderer was provided, use that to output data
      # If not, then just push any output to an array
      if renderer
        output = renderer
        output @_spaces()
      else
        scoped = yes
        output = (msg)-> inner.push msg


      # Create opening tag
      @_openingTag name, output, opts

      # If this is a self-closing, then just return it.
      if name in selfClosing
        if not scoped then output @_newLine()
        return inner.join ''

      # Goes through the remaining arguments, looping through them
      # and appending their content to the body of this tag
      unless @_tagBody name, output, opts
        output @_spaces()
      @_closingTag name, output, scoped
      inner.join ''

  _openingTag: (name, output, opts)->
    attrs = opts[0]
    output "<#{name}"
    if typeof attrs is 'object'
      for attr, val of attrs
        output " #{attr}=\"#{val}\""
      opts.shift()
    output ">"

  _tagBody: (name, output, opts)->
    endString = yes
    while arg = opts.shift()
      if typeof arg in printables
        output arg.toString()
        endString = yes
      else if typeof arg is 'function'
        output @_newLine()
        @_indent()
        arg()
        @_outdent()
        endString = no
    endString

  _closingTag: (name, output, scoped)->
    # Output the ending tag.  If the line ended with a child block,
    # then indent the closing tag, otherwise print it inline.
    output "</#{name}>"
    if not scoped then output @_newLine()


module.exports = Parser
