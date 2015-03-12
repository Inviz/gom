minify = require('html-minifier').minify unless minify
chai = require 'chai' unless chai
GOM = require '../index' unless GOM

{expect,assert} = chai

expectHTML = (gom,html) ->
  renderer = GOM()
  expect(renderer.render(gom))
  .to
  .equal minify( html, {collapseWhitespace:true, keepClosingSlash:true}) # dangerous!!

toHTML = (name,gom,html) ->
  it name, ->
    expectHTML gom, html


$ = GOM()

describe "Helpers", ->

  it 'append()', ->
    node = $ 'div',
      id: 'mommy'
      class:['parent thing']
    $.append node, $ 'div',
      id: 'baby1'
      class:['child thing']
    $.append node, $ 'div',
      id: 'baby2'
      class:['child thing']
    expectHTML node,
      """
        <div id="mommy" class="parent thing">
          <div id="baby1" class="child thing"></div>
          <div id="baby2" class="child thing"></div>
        </div>
      """

  it 'prepend()', ->
    node = $ 'div',
      id: 'mommy'
      class:['parent thing']
    $.prepend node, $ 'div',
      id: 'baby1'
      class:['child thing']
    $.prepend node, $ 'div',
      id: 'baby2'
      class:['child thing']
    expectHTML node,
      """
        <div id="mommy" class="parent thing">
          <div id="baby2" class="child thing"></div>
          <div id="baby1" class="child thing"></div>
        </div>
      """

  it 'addClass()', ->
    node = $ 'div'
    $.addClass node, 'foo'
    $.addClass node, 'bar'
    $.addClass node, ['boom','bang','foo','bar']
    $.addClass node, ['boom','bang','foo','bar']
    expectHTML node,
      """
        <div class="foo bar boom bang"></div>
      """

  it 'removeClass()', ->
    node = $ 'div'
    $.addClass node, 'foo'
    $.addClass node, 'bar'
    $.addClass node, ['boom','bang','foo','bar']
    $.removeClass node, 'bar'
    $.removeClass node, ['bang','foo','bar']
    expectHTML node,
      """
        <div class="boom"></div>
      """

  it 'hasClass()', ->
    node = $ 'div'
    chai.expect($.hasClass(node,'foo')).to.be.false
    $.addClass node, 'foo'
    chai.expect($.hasClass(node,'foo')).to.be.true
    $.addClass node, 'bar'
    chai.expect($.hasClass(node,['foo','bar'])).to.be.true
    chai.expect($.hasClass(node,['foo','bang','bar'])).to.be.false
  
  describe 'get & set Attribute', ->

    test = (name, node, passThrough = false) ->
      it name, ->        
        $.setAttribute node, 'foo', 'bar'
        chai.expect($.getAttribute(node,'foo')).to.eql 'bar'
        $.setAttribute node, 'foo', 'bang'
        chai.expect($.getAttribute(node,'foo')).to.eql 'bang'
        $.setAttribute node, 'hello', 'world'
        expectHTML node,
          """
            <div foo="bang" hello="world"></div>
          """
    
    passThroughTest = (name, node, result) ->
      it name, ->        
        $.setAttribute node, 'foo', 'bar'
        chai.expect($.getAttribute(node,'foo')).to.not.eql 'bar'
        $.setAttribute node, 'foo', 'bang'
        chai.expect($.getAttribute(node,'foo')).to.not.eql 'bar'
        $.setAttribute node, 'hello', 'world'
        expectHTML node, result
    
    test "with an explicit node", $('div')
    test "with an implicit node", {tag:'div'}
    passThroughTest "with a string", "hello", "hello"
    passThroughTest "with a function", () ->
        "hello"
      , "hello"