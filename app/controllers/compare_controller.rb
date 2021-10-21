class CompareController < ApplicationController
  def readModels
    models = Motorbike.where(brand_id: params[:brandId], style_id: params[:styleId]).order(year: :desc).pluck(:id, :name, :year)
    render json: {result: true, models: models}
  end
  def getBikeThumbUrl
    # url = ActionController::Base.helpers.asset_path('bikeThumbs/No' + params[:bikeId] + '.png')
    motorbike = findRecord(params[:bikeId], Motorbike)
    if motorbike
      render json: {result: true, url: motorbike.url}
    else
      render json: {result: false}
    end
  end

  def index
    @brands = Hash.new
    Brand.all.each do |brand|
      @brands[brand.name_kr] = {'id' => brand.id, 'name_kr' => brand.name_kr}
    end

    @styles = Hash.new
    Style.all.each do |style|
      @styles[style.name] = {'id' => style.id, 'name' => style.name}
    end

    updateBestComparisons(1)
    @bestComparisons = parseBestComparisons()
    logger.info @bestComparisons

    # @brands = Brand.all.pluck(:name_kr, :id)
    # @styles = Style.all.pluck(:name, :id)
  end

  def parseBestComparisons()
    content = MiscArchive.find_by(kind: 'best comparisons').content.split(',')
    comparisons = Array.new
    content.each do |comparison|
      ids = comparison.split('-')
      motorbikes = Array.new
      ids.each do |id|
        motorbike = findRecord(id, Motorbike)
        if motorbike
          motorbikes.push({id: motorbike.id, url: motorbike.url, year: motorbike.year, name: motorbike.name})
        end
      end
      comparisons.push(motorbikes)
    end
    return comparisons
  end
  def getBestComparisons()
    comparisons = BikeComparison.select(:bikeIds, :viewCount) .order(viewCount: :desc).limit(2)
    stringify = ''
    comparisons.each do |comparison|
      stringify += comparison.bikeIds + ','
    end
    return stringify[0...-1]
  end
  def updateBestComparisons(interval)
    bestComparisons = MiscArchive.find_by(kind: 'best comparisons')
    if bestComparisons
      diff = (Time.zone.now - bestComparisons.updated_at)/1.day
      if diff > interval and bestComparisons.state.eql? 'updated'
        bestComparisons.update(content: getBestComparisons())
      end
    else
      MiscArchive.new(kind: 'best comparisons', content: getBestComparisons(), state: 'updated').save
    end
  end

  def compareView
    @bikeIds = Array.new
    request.query_parameters.each do |param|
      if Motorbike.exists?(param[1])
        @bikeIds.push(param[1].to_i)
      else
        redirect_to :back
      end
    end

    @bikeComparison = nil
    if @bikeIds.count <= 2
      bikeIds = @bikeIds.sort.join('-')# BikeComparison에 저장할때는 sort 사용해서 오름차순(ascending)으로 저장
      @bikeComparison = BikeComparison.find_by(bikeIds: bikeIds)
      if @bikeComparison.nil?
        @bikeComparison = BikeComparison.new(bikeIds: @bikeIds.join('-'), viewCount: 1)
        @bikeComparison.save
      else
        @bikeComparison.update(viewCount: @bikeComparison.viewCount+1)
      end
    end

    @compareBikes = Array.new
    @bikeIds.each do |id|
      motorbike = findRecord(id, Motorbike)
      if motorbike
        @compareBikes.push(motorbike)
      end
    end
  end

  def readComments
    # 	params timelineId, offset, count
    bikeComparison = findRecord(params[:entityId], BikeComparison)
    if bikeComparison
      comparisonComments = bikeComparison.comparison_comments.order(created_at: :asc).limit(params[:limit]).offset(params[:offset])
      unless comparisonComments.empty?
        writers = Hash.new
        ratings = Hash.new
        replies = Hash.new
        comparisonComments.each do|comment|
          writers[comment.id] = {'name' => comment.user.name, 'avatar_url' => comment.user.avatar, 'titleOfLevel' => comment.user.titleOfLevel}
          ratings[comment.id] = session[:logined] ? getMyRating('comparisonComment', comment) : 0
          replies[comment.id] = comment.replyCount
        end
        render json: {result: true, message: 'success!!', commentCount: comparisonComments.count, comments: comparisonComments, writers: writers, ratings: ratings, replies: replies}
      else
        render json: {result: true, message: 'success but commentCount is Zero!!', commentCount: 0}
      end
    end
  end
  def rateComment
    user = findUser(params[:userId])
    if user
      comparisonComment = findRecord(params[:commentId], ComparisonComment)
      if comparisonComment
        rating = ComparisonCommentRating.find_by(user: user, comparison_comment: comparisonComment)
        if rating
          rating.update(rating: (rating.rating == 1) ? 0 : 1)
          likeCount = comparisonComment.comparison_comment_ratings.where(rating: 1).count
          comparisonComment.update(likeCount: likeCount)
          if rating.rating == 1 and user.id != comparisonComment.user.id
            Notification.new(kind: 'new-like-comparisonComment', content: comparisonComment.content, fromRefId: user.id, toRefId: comparisonComment.bike_comparison.id, user: comparisonComment.user).save
          end
          render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
        else
          rating = ComparisonCommentRating.new(rating: 1, user: user, comparison_comment: comparisonComment)
          if rating.save
            likeCount = comparisonComment.comparison_comment_ratings.where(rating: 1).count
            comparisonComment.update(likeCount: likeCount)
            if user.id != comparisonComment.user.id
              Notification.new(kind: 'new-like-comparisonComment', content: comparisonComment.content, fromRefId: user.id, toRefId: comparisonComment.bike_comparison.id, user: comparisonComment.user).save
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
      render json: {result: false, message: 'cannot find user'}
    end
  end
  def createComment
    user = findUser(params[:userId])
    if user
      if timeSinceLastActivity(user, 'comparisonComment')
        bikeComparison = findRecord(params[:entityId], BikeComparison)
        if bikeComparison
          comment = ComparisonComment.new(content: params[:content], user: user, bike_comparison: bikeComparison, likeCount: 0, replyCount: 0)
          if comment.save
            updateUserExp('comment', user)
            user.last_activity.update(kind: 'comparisonComment', refId: comment.id)
            render json: {result: true, message: 'success!', comment: comment, user: user}
          else
            render json: {result: false, message: '데이터베이스에 저장할 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
          end
        else
          render json: {result: false, message: '바이크비교를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
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
      comparisonComment = findRecord(params[:commentId], ComparisonComment)
      if comparisonComment
        comparisonComment.update(content: params[:content])
        render json: {result: true, content: comparisonComment.content, message: 'success!'}
      else
        render json: {result: false, message: '해당 댓글을 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
      end
    else
      render json: {result: false, message: '유저를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
    end
  end
  def deleteComment
    comparisonComment = findRecord(params[:commentId], ComparisonComment)
    if comparisonComment
      user = findUser(params[:userId])
      if user
        if comparisonComment.user_id == user.id
          if comparisonComment.replyCount > 0
            comparisonComment.update(state: 2)#답글이 있을경우 존재유지
          else
            comparisonComment.destroy
          end
          render json: {result: true, state: comparisonComment.state}
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
  def reportComment
    user = findUser(params[:userId])
    comparisonComment = findRecord(params[:commentId], ComparisonComment)
    if user and comparisonComment
      if ComparisonCommentReport.exists?(user: user, comparison_comment: comparisonComment)
        render json: {result: false, message: "이미 신고한 댓글 입니다."}
      else
        reportItem = ReportItem.find_by(content: params[:itemContent])
        if reportItem
          ComparisonCommentReport.new(user: user, comparison_comment: comparisonComment, report_item: reportItem, content: params[:content], state: 1).save
          render json: {result: true, message: "성공적으로 신고 되었습니다."}
        else
          render json: {result: false, message: "리포트아이템을 찾을 수 없습니다."}
        end
      end
    else
      render json: {result: false, message: "댓글을 찾일 수 없습니다."}
    end
  end

  def readReplies
    comparisonComment = findRecord(params[:commentId], ComparisonComment)
    if comparisonComment
      comparisonReplies = comparisonComment.comparison_replies.order(created_at: :asc).limit(params[:limit]).offset(params[:offset])
      if comparisonReplies.count > 0
        writers = Hash.new
        ratings = Hash.new
        comparisonReplies.each do|reply|
          writers[reply.id] = {'name' => reply.user.name, 'avatar_url' => reply.user.avatar, 'titleOfLevel' => reply.user.titleOfLevel}
          ratings[reply.id] = session[:logined] ? getMyRating('comparisonReply', reply) : 0
        end
        last = comparisonReplies.count < params[:limit].to_i ? true : false
        render json: {result: true, last: last, replies: comparisonReplies, writers: writers, ratings: ratings}
      else
        render json: {result: true, last: true}
      end
    else
      render json: {result: false, message: '해당 댓글을 찾을 수 없습니다.'}
    end
  end
  def rateReply
    user = findUser(params[:userId])
    if user
      comparisonReply = findRecord(params[:replyId], ComparisonReply)
      if comparisonReply
        comparisonReplyRating = ComparisonReplyRating.find_by(user: user, comparison_reply: comparisonReply)
        if comparisonReplyRating
          comparisonReplyRating.update(rating: (comparisonReplyRating.rating == 1) ? 0 : 1)
          likeCount = comparisonReply.comparison_reply_ratings.where(rating: 1).count
          comparisonReply.update(likeCount: likeCount)
          if comparisonReply.rating == 1 and comparisonReply.user.id != user.id
            Notification.new(kind: 'new-like-comparisonReply', content: comparisonReply.content, fromRefId: user.id, toRefId: comparisonReply.comparison_comment.bike_comparison.id, user: comparisonReply.user).save
          end
          render json: {result: true, rating: comparisonReplyRating, likeCount: likeCount, message: 'success!!'}
        else
          comparisonReplyRating = ComparisonReplyRating.new(rating: 1, user: user, comparison_reply: comparisonReply)
          if comparisonReplyRating.save
            likeCount = comparisonReply.comparison_reply_ratings.where(rating: 1).count
            comparisonReply.update(likeCount: likeCount)
            if comparisonReply.user.id != user.id
              Notification.new(kind: 'new-like-comparisonReply', content: comparisonReply.content, fromRefId: user.id, toRefId: comparisonReply.comparison_comment.bike_comparison.id, user: comparisonReply.user).save
            end
            render json: {result: true, rating: comparisonReplyRating, likeCount: likeCount, message: 'success!!'}
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
      if timeSinceLastActivity(user, 'comparisonReply')
        comparisonComment = findRecord(params[:commentId], ComparisonComment)
        if comparisonComment
          comparisonReply = ComparisonReply.new(content: params[:content], comparison_comment: comparisonComment, user: user, likeCount: 0)
          if comparisonReply.save
            updateUserExp('reply', user)
            user.last_activity.update(kind: 'comparisonReply', refId: comparisonReply.id)
            comparisonComment.update(replyCount: comparisonComment.comparison_replies.count)
            if comparisonComment.user.id != user.id
              Notification.new(kind: 'new-reply-comparisonComment', content: params[:content], fromRefId: comparisonReply.id, toRefId: comparisonComment.bike_comparison.id, user: comparisonComment.user).save
            end
            writer = {'name' => user.name, 'avatar_url' => user.avatar, 'titleOfLevel' => user.titleOfLevel}
            render json: {result: true, message: 'success!', reply: comparisonReply, writer: writer}
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
      comparisonReply = findRecord(params[:replyId], ComparisonReply)
      if comparisonReply
        comparisonReply.update(content: params[:content])
        if comparisonReply.save
          render json: {result: true, content: comparisonReply.content, message: 'success!'}
        else
          render json: {result: false, content: comparisonReply.content, message: 'cannot save reply!'}
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
      comparisonReply = ComparisonReply.find_by(id: params[:replyId], user: user)
      if comparisonReply
        comparisonComment = comparisonReply.comparison_comment
        comparisonReply.destroy
        comparisonComment.update(replyCount: comparisonComment.comparison_replies.count)
        render json: {result: true, message: 'success!'}
      else
        render json: {result: false, message: 'cannot find reply!'}
      end
    end
  end
  def reportReply
    user = findUser(params[:userId])
    comparisonReply = findRecord(params[:replyId], ComparisonReply)
    if user and comparisonReply
      if ComparisonReplyReport.exists?(user: user, comparison_reply: comparisonReply)
        render json: {result: false, message: "이미 신고한 답글 입니다."}
      else
        reportItem = ReportItem.find_by(content: params[:itemContent])
        if reportItem
          ComparisonReplyReport.new(user: user, comparison_reply: comparisonReply, report_item: reportItem, content: params[:content], state: 1).save
          render json: {result: true, message: "성공적으로 신고 되었습니다."}
        else
          render json: {result: false, message: "리포트아이템을 찾을 수 없습니다."}
        end
      end
    else
      render json: {result: false, message: "답글을 찾일 수 없습니다."}
    end
  end

  def readBikeComparison
    user = findUser(params[:userId])
    if user
      bikeComparison = findRecord(params[:bikeComparisonId], BikeComparison)
      if bikeComparison
        render json: {result: true, bikeComparison: bikeComparison}
      else
        render json: {result: false, message: "cannot find bikeComparison"}
      end
    else
      render json: {result: false, message: "cannot find user"}
    end
  end

end
