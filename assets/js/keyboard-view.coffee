class window.KeyboardView
  constructor: ->
    @socket = new WebSocket "ws://#{location.host}/"

    @socket.onopen = =>
      @touches = {}

      document.addEventListener "touchstart", @touchStart, false
      document.addEventListener "touchmove", @touchMove, false
      document.addEventListener "touchend", @touchEnd, false

  touchStart: (event) =>
    touch = event.targetTouches[event.targetTouches.length - 1]

    @touches[touch.identifier] = { x: touch.pageX, y: touch.pageY }

    if event.targetTouches.length == 2
      @lastMouseX = event.targetTouches[0].pageX
      @lastMouseY = event.targetTouches[0].pageY

    event.preventDefault()

  touchMove: (event) =>
    if event.targetTouches.length == 2
      mouseX = event.targetTouches[0].pageX
      mouseY = event.targetTouches[0].pageY
      deltaMouseX = mouseX - @lastMouseX
      deltaMouseY = mouseY - @lastMouseY

      @lastMouseX = mouseX
      @lastMouseY = mouseY

      @socket.send JSON.stringify({type: 'mouseMove', x: deltaMouseX, y: deltaMouseY })

    event.preventDefault()

  touchEnd: (event) =>
    for touch in event.changedTouches
      delete @touches[touch.identifier]

    event.preventDefault()

  triggerKeyboardEvent: =>
    @socket.send JSON.stringify({type: 'keyDown', keyCode: '7'})
