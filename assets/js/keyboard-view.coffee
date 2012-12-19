class window.KeyboardView
  constructor: ->
    @touches = {}
    @mouseSensitivity = 15 #TODO: Make configurable
    @socket = new WebSocket "ws://#{location.host}/"

    @socket.onopen = =>
      document.addEventListener "touchstart", @touchStart, false
      document.addEventListener "touchmove", @touchMove, false
      document.addEventListener "touchend", @touchEnd, false

  touchStart: (event) =>
    event.preventDefault()

    touch = event.targetTouches[event.targetTouches.length - 1]

    @touches[touch.identifier] = touch

    if event.targetTouches.length > 1
      firstTouch = event.targetTouches[0]

      @lastMouseX = firstTouch.pageX
      @lastMouseY = firstTouch.pageY
      @lastMouseTime = new Date().getTime()

  touchMove: (event) =>
    event.preventDefault()

    if event.targetTouches.length > 1
      mouseX = event.targetTouches[0].pageX
      mouseY = event.targetTouches[0].pageY
      mouseTime = new Date().getTime()
      mouseXDelta = mouseX - @lastMouseX
      mouseYDelta = mouseY - @lastMouseY
      mouseTimeDelta = mouseTime - @lastMouseTime
      pixelDistance = Math.sqrt((mouseXDelta * mouseXDelta) + (mouseYDelta * mouseYDelta))
      mouseVelocity = pixelDistance / mouseTimeDelta
      mouseSpeed = mouseVelocity * @mouseSensitivity
      translateMouseX = mouseXDelta * mouseSpeed
      translateMouseY = mouseYDelta * mouseSpeed
      message = { type: 'mouseMove', x: translateMouseX, y: translateMouseY }

      @lastMouseX = mouseX
      @lastMouseY = mouseY
      @lastMouseTime = mouseTime

      @socket.send JSON.stringify(message)

  touchEnd: (event) =>
    event.preventDefault()

    for touch in event.changedTouches
      delete @touches[touch.identifier]

  triggerKeyboardEvent: =>
    @socket.send JSON.stringify({type: 'keyDown', keyCode: '7'})
