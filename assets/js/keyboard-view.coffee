class window.KeyboardView extends View
  @content: ->
    @div "I AM A KEYBOARD", click: 'triggerKeyboardEvent'

  triggerKeyboardEvent: ->
    $.post '/keydown-event/7'
