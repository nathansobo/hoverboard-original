#= require "jquery"
#= require "space-pen"
#= require "keyboard-view"

$ ->
  socket = new WebSocket "ws://localhost:8080/"

  socket.onopen = ->
    $('body').append(new KeyboardView({socket: socket}))
