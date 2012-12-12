class window.KeyboardView
  constructor: ->
    @socket = new WebSocket "ws://#{location.host}/"

    @socket.onopen = =>
      document.addEventListener "touchstart", @touchStart, false
      document.addEventListener "touchmove", @touchMove, false
      document.addEventListener "touchend", @touchEnd, false

  touchStart: (event) ->
    event.preventDefault()
    console.log 'touchStart'

  touchMove: (event) ->
    event.preventDefault()
    console.log 'touchMove'

  touchEnd: (event) ->
    event.preventDefault()
    console.log 'touchEnd'

  triggerKeyboardEvent: ->
    @socket.send JSON.stringify({type: 'keyDown', keyCode: '7'})
