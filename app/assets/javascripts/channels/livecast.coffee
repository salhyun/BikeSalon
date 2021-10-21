$(document).on 'turbolinks:load', ->
  console.log('%c turbolink loaded', 'color: red');
  $livecastTitle = $('#livecast-property')
  if $livecastTitle.length > 0
    livecastId = $('#livecast-property').data('livecastid')
    userId = $('#livecast-property').data('userid')

    App.livecast = App.cable.subscriptions.create {channel: "LivecastChannel", livecastId: livecastId, userId: userId},
      connected: ->
        console.log('Connected to livecast ' + livecastId + ' channel...');

      disconnected: ->
        console.log('Disconnected livecast ' + livecastId + ' channel...');

      received: (data) ->
        console.log('received message:', data.message);
        addMessage(data.message, data.name);

      speak: (message, name) ->
        @perform 'messaging', message: message, name: name

      kickout: (userId) ->
        @perform 'kickout', userId: userId
  else
    console.log('%c Not livecast Page', 'background: black, color: green')


#App.livecast = App.cable.subscriptions.create {channel: "LivecastChannel", livecastId: 3},
#  connected: ->
#    # Called when the subscription is ready for use on the server
#    console.log('Connected to livecast channel...');
#
#  disconnected: ->
#    # Called when the subscription has been terminated by the server
#
#  received: (data) ->
#    # Called when there's incoming data on the websocket for this channel
#    console.log('received message:', data.message);
#
#  speak: (message) ->
#    @perform 'speak', message: message

