Parser = require '../lib/index'
fs   = require 'fs'
path = require 'path'

loadSamples = (name)->
  samples = []
  source = fs.readFileSync(path.join __dirname, "samples/#{name}.html").toString().trim()
  parts = source.split '==='
  for part in parts
    samples.push part.split '---'
  samples

describe 'csml', ->
  csml = undefined
  beforeEach ->
    csml = new Parser()

  describe 'render', ->

    it 'renders basic tags', ->
      samples = loadSamples 'basic'
      for sample in samples
        expect(csml.render(sample[0].trim()).trim()).toEqual sample[1].trim()

    it 'renders samples with context', ->
      samples = loadSamples 'context'
      context =
        title: 'Hello World!'
        turtles: ['Leonardo', 'Donatello', 'Raphael', 'Michaelangelo']

      for sample in samples
        rendered = csml.render(sample[0].trim(), context).trim()
        expect(rendered).toEqual sample[1].trim()

    it 'lets you set spaces', ->
      csml.tab = 4
      input = ["div id: 'content', ->", "  p 'Hello World'"].join "\n"
      output = ['<div id="content">', '    <p>Hello World</p>', '</div>', ''].join "\n"
      expect(csml.render input).toEqual output


    it 'condenses html', ->
      csml.tab = 4
      input = ["div id: 'content', ->", "  p 'Hello World'"].join "\n"
      output = ['<div id="content">', '<p>Hello World</p>', '</div>', ''].join ''
      expect(csml.condense input).toEqual output

      output = ['<div id="content">', '    <p>Hello World</p>', '</div>', ''].join "\n"
      expect(csml.render input).toEqual output

