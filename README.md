# CSML
#### CoffeeScript Markup Language

*CSML* is a small experiment in writing a pure CoffeeScript DSL.  CSML is pure CoffeeScript
that is converted into HTML.

## Examples
Using the parser:

    CSML = require 'csml'
    parser = new CSML()
    console.log parser.render text

Example of CSML:

```coffee-script
html lang: 'en', ->
  head ->
    link type: 'text/css', rel: 'stylesheet', href: '/style.css'
    script type: 'text/javascript', src: 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'
  body ->
    h1 'Hello World!'
    div id: 'contents', ->
      h2 id: 'subheader', 'Welcome to my example site!'
      p "What about a break tag?", br(), "HANNAH?"
      p "What about a break tag?#{b('Barf!')}HANNAH?"
      ul id: 'kids', ->
        for num in [1..4]
          li num
```

Produces the following HTML:

```html
<html lang="en">
  <head>
    <link type="text/css" rel="stylesheet" href="/style.css">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
  </head>
  <body>
    <h1>Hello World!</h1>
    <div id="contents">
      <h2 id="subheader">Welcome to my example site!</h2>
      <p>What about a break tag?<br>HANNAH?</p>
      <p>What about a break tag?<b>Barf!</b>HANNAH?</p>
      <ul id="kids">
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
      </ul>
    </div>
  </body>
</html>
```
