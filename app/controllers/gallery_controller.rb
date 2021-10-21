class GalleryController < ApplicationController

  def readTimelines
    logger.info('gallery post')
    timelines = []
    if params[:searchWord].length > 0
      # timelines = Timeline.where(public: true).where("title like ? OR desc like ? OR category like ?", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%").order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
      # timelines = timelines.where("title like ?", "%#{params[:searchWord]}%")
      if params[:searchWord][0] == '#'
        hashtag = Hashtag.all.find_by(word: params[:searchWord][1..-1])
        if params[:offset] == '0'
          hashtag.update(searchCount: hashtag.searchCount+1)
        end
        timelines = hashtag.timelines.order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
      else
        timelines = Timeline.where(public: true).where("title like ? OR category like ? OR cachedHashtags like ?", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%").order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
      end
    else
      timelines = Timeline.where(public: true).order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
    end
    unless timelines.empty?
      misc = Hash.new
      timelines.each do|timeline|
        misc[timeline.id] = {'name' => timeline.user.name,
                             'avatar_url' => timeline.user.avatar,
                             'ratingNum' => timeline.likeCount, #timeline.timeline_ratings.where(rating: 1).count,
                             'commentNum' => timeline.commentCount, #timeline.comments.count,
                             'titleOfLevel' => timeline.user.titleOfLevel,
                             'categoryColor' => TimelineCategory.find_by(name: timeline.category).color,
                             'attachments' => timeline.timeline_attachments,
                             'timelineLocation' => timeline.timeline_location}
      end
      render json: {result: true, message: 'success!!', timelineCount: timelines.count, timelines: timelines, misc: misc}
    else
      render json: {result: true, message: 'there is no more timeline!', timelineCount: timelines.count}
    end
  end

  def readComments
    # 	params timelineId, offset, count
    timeline = findRecord(params[:entityId], Timeline)
    if timeline
      comments = timeline.comments.order(created_at: :asc).limit(params[:limit]).offset(params[:offset])
      unless comments.empty?
        writers = Hash.new
        ratings = Hash.new
        replies = Hash.new
        comments.each do|comment|
          writers[comment.id] = {'name' => comment.user.name, 'avatar_url' => comment.user.avatar, 'titleOfLevel' => comment.user.titleOfLevel}
          ratings[comment.id] = session[:logined] ? getMyRating('comment', comment) : 0
          replies[comment.id] = comment.replyCount
        end
        render json: {result: true, message: 'success!!', commentCount: comments.count, comments: comments, writers: writers, ratings: ratings, replies: replies}
      else
        render json: {result: true, message: 'success but commentCount is Zero!!', commentCount: 0}
      end
    end
  end

  # def getMyRating(timeline)
  #   myRating = 0
  #   if session[:logined]
  #     user = findUser(session[:user]['id'])
  #     if user
  #       rating = TimelineRating.find_by(user: user, timeline: timeline)
  #       if rating
  #         myRating = rating.rating
  #       end
  #     end
  #   end
  #   return myRating
  # end

  def gallery
    if request.post?
      logger.info("request.post?")
      timeline = findRecord(params[:timelineId], Timeline)
      if timeline
        writer = timeline.user
        if session[:logined]
          if session[:user]['id'] != writer.id
            timeline.update(viewCount: timeline.viewCount+1)
          end
        else
          timeline.update(viewCount: timeline.viewCount+1)
        end
        render json: {result: true, message: 'success!!', timeline: timeline, attachments: timeline.timeline_attachments, myRating: session[:logined] ? getMyRating('timeline', timeline) : 0, comment_count: timeline.comments.count, writer: writer, mybikeId: timeline.mybike.id, timelineLocation: timeline.timeline_location, hashtags: timeline.hashtags.pluck(:id, :word)}
      else
        render json: {result: false, message: '해당 타임라인을 찾을 수 없습니다. 새로고침후 다시 시도하세요'}
      end
    else
      @hashtag = params.has_key?(:hashtag) ? params[:hashtag] : ''
      if params.has_key?(:page) && params.has_key?(:scroll)
        logger.info("params has page & scroll key")

        timelines = Timeline.where(public: true)
        @pageSize = 6
        @offset = params[:page]
        @publicTimelines = timelines.order(created_at: :desc).limit(@pageSize).offset(@offset)
        # @publicTimelines = timelines.order(created_at: :desc)
      else
        logger.info("params hasn't page & scroll key")

        timelines = Timeline.where(public: true)
        @pageSize = 6
        @timelineSize = Timeline.count
        @maxPage = @timelineSize/@pageSize
        @offset = 0
        @publicTimelines = timelines.order(created_at: :desc).limit(@pageSize).offset(@offset)
      end
    end
  end

  def rateComment
    user = findUser(params[:userId])
    if user
      comment = findRecord(params[:commentId], Comment)
      if comment
        rating = CommentRating.find_by(user: user, comment: comment)
        if rating
          rating.update(rating: (rating.rating == 1) ? 0 : 1)
          likeCount = comment.comment_ratings.where(rating: 1).count
          comment.update(likeCount: likeCount)
          if rating.rating == 1 and comment.user.id != user.id
            Notification.new(kind: 'new-like-comment', content: comment.content, fromRefId: user.id, toRefId: comment.timeline.id, user: comment.user).save
          end
          render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
        else
          rating = CommentRating.new(rating: 1, user: user, comment: comment)
          if rating.save
            likeCount = comment.comment_ratings.where(rating: 1).count
            comment.update(likeCount: likeCount)
            if comment.user.id != user.id
              Notification.new(kind: 'new-like-comment', content: comment.content, fromRefId: user.id, toRefId: comment.timeline.id, user: comment.user).save
            end
            render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
          else
            render json: {result: false , message: 'cannot save database!'}
          end
        end
      else
        render json: {result: false, message: 'cannot find comment'}
      end
    else
      render json: {result: false , message: 'unknown user!'}
    end
  end

  def createComment
    user = findUser(params[:userId])
    if user
      if timeSinceLastActivity(user, 'comment')
        timeline = findRecord(params[:entityId], Timeline)
        if timeline
          comment = Comment.new(content: params[:content], user: user, timeline: timeline)
          if comment.save
            updateUserExp('comment', user)
            user.last_activity.update(kind: 'comment', refId: comment.id)
            commentCount = timeline.comments.count
            timeline.update(commentCount: commentCount)
            Notification.new(kind: 'new-comment-timeline', content: params[:content], fromRefId: comment.id, toRefId: timeline.id, user: timeline.user).save
            render json: {result: true, message: 'success!', comment: comment, user: user}
          else
            render json: {result: false, message: '데이터베이스에 저장할 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
          end
        else
          render json: {result: false, message: '타임라인을 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
        end
      else
        render json: {result: false, message: '비정상적인 서비스 이용입니다.'}
      end
    else
      render json: {result: false, message: '유저를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
    end
  end

  def modifyComment
    user = findUser(params[:userId])
    if user
      comment = findRecord(params[:commentId], Comment)
      if comment
        comment.update(content: params[:content])
        if comment.save
          render json: {result: true, content: comment.content, message: 'success!'}
        else
          render json: {result: false, content: comment.content, message: 'cannot save comment!'}
        end
      else
        render json: {result: false, message: '해당 댓글을 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
      end
    else
      render json: {result: false, message: '유저를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
    end
  end

  def deleteComment
    logger.info('deleteComment')
    comment = findRecord(params[:commentId], Comment)
    if comment
      user = findUser(params[:userId])
      if user
        if comment.user_id == user.id
          if comment.replyCount > 0
            comment.update(state: 2)#답글이 있을경우 존재유지
          else
            timeline = comment.timeline
            comment.destroy
            timeline.update(commentCount: timeline.comments.count)
          end
          render json: {result: true, state: comment.state}
        else
          render json: {result: false, message: '유저가 일치 하지 않습니다. 새로고침 후 다시 시도하세요!'}
        end
      else
        render json: {result: false, message: '유저를 찾을 수 없습니다. 새로고침 후 다시 시도하세요!'}
      end
    else
      render json: {result: false, message: '해당 댓글을 찾을 수 없습니다. 새로고침 후 다시 시도하세요!'}
    end
  end

  def readReplies
    comment = findRecord(params[:commentId], Comment)
    if comment
      replies = comment.replies.order(created_at: :asc).limit(params[:limit]).offset(params[:offset])
      if replies.count > 0
        writers = Hash.new
        ratings = Hash.new
        replies.each do|reply|
          writers[reply.id] = {'name' => reply.user.name, 'avatar_url' => reply.user.avatar, 'titleOfLevel' => reply.user.titleOfLevel}
          ratings[reply.id] = session[:logined] ? getMyRating('reply', reply) : 0
        end
        last = replies.count < params[:limit].to_i ? true : false
        render json: {result: true, last: last, replies: replies, writers: writers, ratings: ratings}
      else
        render json: {result: true, last: true}
      end
    else
      render json: {result: false, message: "해당 댓글을 찾을 수 없습니다."}
    end
  end

  def rateReply
    user = findUser(session[:user]['id'])
    if user
      reply = findRecord(params[:replyId], Reply)
      if reply
        rating = ReplyRating.find_by(user: user, reply: reply)
        if rating
          rating.update(rating: (rating.rating == 1) ? 0 : 1)
          likeCount = reply.reply_ratings.where(rating: 1).count
          reply.update(likeCount: likeCount)
          if rating.rating == 1 and reply.user.id != user.id
            Notification.new(kind: 'new-like-reply', content: reply.content, fromRefId: user.id, toRefId: reply.comment.timeline.id, user: reply.user).save
          end
          render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
        else
          rating = ReplyRating.new(rating: 1, user: user, reply: reply)
          if rating.save
            likeCount = reply.reply_ratings.where(rating: 1).count
            reply.update(likeCount: likeCount)
            if reply.user.id != user.id
              Notification.new(kind: 'new-like-reply', content: reply.content, fromRefId: user.id, toRefId: reply.comment.timeline.id, user: reply.user).save
            end
            render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
          else
            render json: {result: false , message: 'cannot save database!'}
          end
        end
      else
        render json: {result: false , message: 'cannot find reply!'}
      end
    else
      render json: {result: false , message: 'cannot find user'}
    end
  end
  def createReply
    user = findUser(params[:userId])
    if user
      if timeSinceLastActivity(user, 'reply')
        comment = findRecord(params[:commentId], Comment)
        if comment
          reply = Reply.new(content: params[:content], comment: comment, user: user)
          if reply.save
            updateUserExp('reply', user)
            user.last_activity.update(kind: 'reply', refId: reply.id)
            comment.update(replyCount: comment.replies.count)
            if comment.user.id != user.id
              Notification.new(kind: 'new-reply-comment', content: params[:content], fromRefId: reply.id, toRefId: comment.id, user: comment.user).save
            end
            writer = {'name' => user.name, 'avatar_url' => user.avatar, 'titleOfLevel' => user.titleOfLevel}
            render json: {result: true, message: 'success!', reply: reply, writer: writer}
          else
            render json: {result: false, message: '데이터베이스에 저장할 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
          end
        else
          render json: {result: false, message: '댓글을 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
        end
      else
        render json: {result: false, message: '비정상적인 서비스 이용 입니다!'}
      end
    else
      render json: {result: false, message: '유저를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
    end
  end
  def modifyReply
    user = findUser(params[:userId])
    if user
      reply = findRecord(params[:replyId], Reply)
      if reply
        reply.update(content: params[:content])
        if reply.save
          render json: {result: true, content: reply.content, message: 'success!'}
        else
          render json: {result: false, content: reply.content, message: 'cannot save reply!'}
        end
      else
        render json: {result: false, message: '해당 답글을 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
      end
    else
      render json: {result: false, message: '유저를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
    end
  end
  def deleteReply
    user = findUser(params[:userId])
    if user
      reply = Reply.find_by(id: params[:replyId], user: user)
      if reply
        comment = reply.comment
        reply.destroy
        comment.update(replyCount: comment.replies.count)
        render json: {result: true, message: 'success!'}
      else
        render json: {result: false, message: 'cannot find reply!'}
      end
    end
  end

  def reportComment
    user = findUser(session[:user]['id'])
    comment = findRecord(params[:commentId], Comment)
    if comment and user
      if CommentReport.exists?(user: user, comment: comment)
        render json: {result: false, message: "이미 신고한 댓글 입니다."}
      else
        reportItem = ReportItem.find_by(content: params[:itemContent])
        if reportItem
          CommentReport.new(user: user, comment: comment, report_item: reportItem, content: params[:content], state: 1).save
          render json: {result: true, message: "성공적으로 신고 되었습니다."}
        else
          render json: {result: false, message: "리포트아이템을 찾을 수 없습니다."}
        end
      end
    else
      render json: {result: false, message: "댓글을 찾일 수 없습니다."}
    end
  end

  def reportReply
    user = findUser(session[:user]['id'])
    reply = findRecord(params[:replyId], Reply)
    if user and reply
      if ReplyReport.exists?(user: user, reply: reply)
        render json: {result: false, message: "이미 신고한 답글 입니다."}
      else
        reportItem = ReportItem.find_by(content: params[:itemContent])
        if reportItem
          ReplyReport.new(user: user, reply: reply, report_item: reportItem, content: params[:content], state: 1).save
          render json: {result: true, message: "성공적으로 신고 되었습니다."}
        else
          render json: {result: false, message: "리포트아이템을 찾을 수 없습니다."}
        end
      end
    else
      render json: {result: false, message: "답글을 찾일 수 없습니다."}
    end
  end

  def mapview
    @categories = TimelineCategory.all
    if params.has_key?(:timelineLocationId)
      logger.info 'mainLocationId = ' + params[:timelineLocationId]
      @mainLocation = findRecord(params[:timelineLocationId], TimelineLocation)
    end
  end

  def readTimelineLocations
    if params[:searchWord].length > 0
      searchWord = params[:searchWord][0] == '#' ? params[:searchWord][1..-1] : params[:searchWord]
      timelineLocations = TimelineLocation.where('lat >= ? AND lat <= ? AND lng >= ? AND lng <= ?', params[:sw]['lat'], params[:ne]['lat'], params[:sw]['lng'], params[:ne]['lng']).where("title like ? OR category like ? OR cachedHashtags like ?", "%#{searchWord}%", "%#{searchWord}%", "%#{searchWord}%").order(likeCount: :desc).limit(params[:limit])
    else
      timelineLocations = TimelineLocation.where('lat >= ? AND lat <= ? AND lng >= ? AND lng <= ?', params[:sw]['lat'], params[:ne]['lat'], params[:sw]['lng'], params[:ne]['lng']).order(likeCount: :desc).limit(params[:limit])
    end
    render json: {result: true, timelineLocations: timelineLocations}
  end

  def readBestHashtags
    bestHashtags = Hashtag.all.order(searchCount: :desc).limit(params[:limit])
    render json: {result: true, bestHashtags: bestHashtags}
  end

end
