class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :detect_locale
  before_action :preAction
  before_action :checkInfomation

  def preAction
    return if request.post?
    url = request.url.split('/')
    @request_ctl = url[url.length-2]
    @request_url = url.last.split('?').first

    if @request_url == 'gallery' or @request_url == 'mapview'  or @request_url == 'timeline' or @request_url == 'mybike' or @request_url == 'rankings' or @request_url == 'reportView' or @request_url == ENV['host_ip']
      session[:enable_detailview] = true
      session[:enable_comment] = true
      @reportItems = ReportItem.all
    elsif @request_url == 'bikeview'
      session[:enable_comment] = true
      session[:enable_detailview] = false
      @reportItems = ReportItem.all
    elsif @request_url == 'compareView'
      session[:enable_comment] = true
      session[:enable_detailview] = false
      @reportItems = ReportItem.all
    else
      session[:enable_detailview] = false
      session[:enable_comment] = false
    end

    @firebase_users_path = 'images/'
    unless ENV['host_ip'].include? 'localhost'
      if Rails.env.eql? 'production'
        @firebase_users_path = 'images/users_aws_pro/'
      else
        @firebase_users_path = 'images/users_aws_dev/'
      end
    end
  end

  def detect_locale
    I18n.locale = request.headers['Accept-Language'].scan(/\A[a-z]{2}/).first
  end

  def checkInfomation
    @userAgent = request.user_agent
    @mobileDevice = ApplicationController.checkMobileDevice(@userAgent)
    @browserInfo = ApplicationController.getBrowserInfo(@userAgent)
  end

  def self.checkMobileDevice(userAgent)
    if userAgent =~ /Android/i or userAgent =~ /iPhone/i
      return true
    end
    return false
  end
  def self.getBrowserInfo(userAgent)
    if userAgent =~ /Chrome/i
      return 'Chrome'
    elsif userAgent =~ /Safari/i
      return 'Safari'
    elsif userAgent =~ /Firefox/i
      return 'Firefox'
    else
      return nil
    end
  end

  def checkMasterAccount(account)
    if account
      if account.eql? ENV['masterAccount']
        return true
      end
    end
    return false
  end

  def findUser(id)
    begin
      user = User.find(id)
    rescue ActiveRecord::RecordNotFound
      return nil
    else
      return user
    end
  end
  def findRecord(id, records)
    begin
      record = records.find(id)
    rescue ActiveRecord::RecordNotFound
      return nil
    else
      return record
    end
  end
  def getMyRating(kind, record)
    rating = nil
    if kind == 'timeline'
      rating = TimelineRating.find_by(user_id: session[:user]['id'], timeline_id: record.id)
    elsif kind == 'comment'
      rating = CommentRating.find_by(user_id: session[:user]['id'], comment_id: record.id)
    elsif kind == 'bikeComment'
      rating = BikeCommentRating.find_by(user_id: session[:user]['id'], bike_comment_id: record.id)
    elsif kind == 'comparisonComment'
      rating = ComparisonCommentRating.find_by(user_id: session[:user]['id'], comparison_comment_id: record.id)
    elsif kind == 'reply'
      rating = ReplyRating.find_by(user_id: session[:user]['id'], reply_id: record.id)
    elsif kind == 'bikeReply'
      rating = BikeReplyRating.find_by(user_id: session[:user]['id'], bike_reply_id: record.id)
    elsif kind == 'comparisonReply'
      rating = ComparisonReplyRating.find_by(user_id: session[:user]['id'], comparison_reply_id: record.id)
    end
    if rating
      return rating.rating
    else
      return 0
    end
  end
  def timeSinceLastActivity(user, kind)
    lastActivity = user.last_activity
    if lastActivity
      if lastActivity.kind.eql? kind and (Time.zone.now - lastActivity.updated_at) < 10
        return false
      else
        return true
      end
    else
      return false
    end
  end
  def updateUserExp(kind, user)
    exp = user.exp
    lastActivity = user.last_activity
    diff = Time.new - lastActivity.updated_at
    if kind == 'mybike'
      unless lastActivity.kind.downcase.include?(kind) and (diff/1.minute) < 10
        exp += 2
      end
    elsif kind == 'timeline'
      unless lastActivity.kind.downcase.include?(kind) and (diff/1.minute) < 5
        exp += 0.75
      end
    elsif kind == 'comment' or kind == 'reply'
      unless lastActivity.kind.downcase.include?(kind) and (diff/1.minute) < 1
        exp += 0.25
      end
    end
    user.update(exp: exp)
  end

  # before_action :enable_detailview, only: [:gallery, :timeline]
  # before_action :disable_detailveiw, except: [:gallery, :timeline]

  # def enable_detailview
  #   return if request.post?
  #   logger.info('enable_detailview')
  #   session[:enable_comment] = true
  #   session[:enable_detailview] = true
  #   @reportItems = ReportItem.all
  # end
  #
  # def disable_detailveiw
  #   return if request.post?
  #   logger.info('disable_detailview')
  #   session[:enable_comment] = false
  #   session[:enable_detailview] = false
  # end

end
