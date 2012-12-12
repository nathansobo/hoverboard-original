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
      currentMouseX = event.targetTouches[0].pageX
      currentMouseY = event.targetTouches[0].pageY
      distanceFromLastMouseX = currentMouseX - @lastMouseX
      distanceFromLastMouseY = currentMouseY - @lastMouseY

      console.log @lastMouseX
      console.log @lastMouseY

      @lastMouseX = currentMouseX
      @lastMouseY = currentMouseY

      @socket.send JSON.stringify({type: 'mouseMove', x: distanceFromLastMouseX, y: distanceFromLastMouseY })

    event.preventDefault()

  touchEnd: (event) =>
    for touch in event.changedTouches
      delete @touches[touch.identifier]

    event.preventDefault()

  triggerKeyboardEvent: =>
    @socket.send JSON.stringify({type: 'keyDown', keyCode: '7'})
