class window.KeyboardView
  constructor: ->
    @touches = {}
    @socket = new WebSocket "ws://#{location.host}/"

    @socket.onopen = =>
      document.addEventListener "touchstart", @touchStart, false
      document.addEventListener "touchmove", @touchMove, false
      document.addEventListener "touchend", @touchEnd, false

  touchStart: (event) =>
    event.preventDefault()

    touch = event.targetTouches[event.targetTouches.length - 1]

    @touches[touch.identifier] = touch

    if event.targetTouches.length == 2
      firstTouch = event.targetTouches[0]

      @lastMouseX = firstTouch.pageX
      @lastMouseY = firstTouch.pageY

  touchMove: (event) =>
    event.preventDefault()

    if event.targetTouches.length == 2
      mouseX = event.targetTouches[0].pageX
      mouseY = event.targetTouches[0].pageY
      deltaMouseX = mouseX - @lastMouseX
      deltaMouseY = mouseY - @lastMouseY

      @lastMouseX = mouseX
      @lastMouseY = mouseY

      @socket.send JSON.stringify({type: 'mouseMove', x: deltaMouseX, y: deltaMouseY })

  touchEnd: (event) =>
    event.preventDefault()

    for touch in event.changedTouches
      delete @touches[touch.identifier]

  triggerKeyboardEvent: =>
    @socket.send JSON.stringify({type: 'keyDown', keyCode: '7'})
