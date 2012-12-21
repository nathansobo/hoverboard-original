class window.KeyboardView
  constructor: ->
    @touches = {}
    @mouseSensitivity = 15 #TODO: Make configurable
    @socket = new WebSocket "ws://#{location.host}/"
    @doubleClickTimeMilliseconds = 420

    @socket.onopen = =>
      document.addEventListener "touchstart", @touchStart, false
      document.addEventListener "touchmove", @touchMove, false
      document.addEventListener "touchend", @touchEnd, false

  touchStart: (event) =>
    event.preventDefault()

    currentTouch = event.targetTouches[event.targetTouches.length - 1]

    if event.targetTouches.length > 1
      firstTouch = event.targetTouches[0]

      @lastMouseX = firstTouch.pageX
      @lastMouseY = firstTouch.pageY
      @lastMouseTime = new Date().getTime()

      if event.targetTouches.length == 3
        button = if currentTouch.pageX > firstTouch.pageX then 'right' else 'left'
        message = { type: "#{button}MouseDown", x: 0, y: 0 }
        timeBetweenMouseDowns = new Date().getTime() - @lastMouseDownTime

        if timeBetweenMouseDowns <= @doubleClickTimeMilliseconds
          console.log 'double clicked'

        @lastMouseButton = button
        @lastMouseDownTime = new Date().getTime()

        @socket.send JSON.stringify(message)

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
      message = {}
      message.type = if @lastMouseButton then "#{@lastMouseButton}MouseDragged" else 'mouseMoved'
      message.x = translateMouseX
      message.y = translateMouseY

      @lastMouseX = mouseX
      @lastMouseY = mouseY
      @lastMouseTime = mouseTime

      @socket.send JSON.stringify(message)

  touchEnd: (event) =>
    event.preventDefault()

    if event.targetTouches.length == 2
      message = { type: "#{@lastMouseButton}MouseUp", x: 0, y: 0 }

      @lastMouseButton = null

      @socket.send JSON.stringify(message)

  triggerKeyboardEvent: =>
    @socket.send JSON.stringify({type: 'keyDown', keyCode: '7'})
