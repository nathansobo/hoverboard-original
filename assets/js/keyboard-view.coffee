class window.KeyboardView extends View
  initialize: (params) ->
    @socket = params.socket

  triggerKeyboardEvent: ->
    @socket.send JSON.stringify({type: 'keydown', keyCode: '7'})
  @content: (params) ->
    @textarea "I AM A KEYBOARD", click: 'triggerKeyboardEvent'
