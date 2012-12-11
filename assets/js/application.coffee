#= require "jquery"
#= require "space-pen"
#= require "keyboard-view"

$ ->
  socket = new WebSocket "ws://#{location.host}/"

  socket.onopen = ->
    $('body').append(new KeyboardView({socket: socket}))
