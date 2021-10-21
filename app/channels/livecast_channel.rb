class LivecastChannel < ApplicationCable::Channel
  def subscribed
    logger.info 'livecast id =' + params[:livecastId].to_s
    # stream_from "some_channel"
    stream_from "livecast_#{params['livecastId']}_channel"

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    logger.info 'unsubscribed'
  end

  def messaging(data)
    logger.info "[ActionCable] received message : #{data['message']}"
    logger.info 'connected users = ' + ActionCable.server.connections.length.to_s

    ActionCable.server.broadcast "livecast_#{params['livecastId']}_channel", message: "#{data['message']}", name: "#{data['name']}"
  end

  def kickout(data)
    user = User.find_by(id: data['userId'])
    if user
      ActionCable.server.remote_connections.where(current_user: user).disconnect
    end
    # ActionCable.server.connections.each do |connection|
    #   logger.info 'connection id = ' + connection.current_user.id.to_s
    # end
  end

end
