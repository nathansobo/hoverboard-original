class window.KeyboardView extends View
  initialize: (params) ->
    @socket = params.socket

  triggerKeyboardEvent: ->
    @socket.send JSON.stringify({type: 'keyDown', keyCode: '7'})

  @content: (params) ->
    @div "I AM A KEYBOARD", click: 'triggerKeyboardEvent'
