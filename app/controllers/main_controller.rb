class MainController < ApplicationController
	
	def view
		@brands = Brand.all
		@styles = Style.all

		@salonNotices = SalonNotice.all
	end
	
	def brandview
		@styleNames = ['네이키드', '스쿠터', '스포츠', '슈퍼스포츠', '듀얼스포츠', '투어링', '크루저', '언더본', '오프로드', '슈퍼모타드', '트라이크']
		@styleIds = [11, 6, 4, 3, 5, 1, 2, 8, 7, 9, 10]
		@styles = Style.all
		@brandId = params[:brandId]
		@brand = findRecord(@brandId, Brand)
		@brandBikes = Motorbike.where(brand_id: @brandId.to_i)
	end

	def updateBikeRating(motorbike)
		ratings = motorbike.bike_ratings
		if ratings.count > 0
			scores = {'total' => 0, 'design' => 0, 'performance' => 0, 'comfort' => 0}
			for rating in ratings do
				scores['design'] += rating.design
				scores['performance'] += rating.performance
				scores['comfort'] += rating.comfort
				scores['total'] += (rating.design + rating.performance + rating.comfort)
			end
			scores['design'] /= ratings.count.to_f
			scores['performance'] /= ratings.count.to_f
			scores['comfort'] /= ratings.count.to_f
			scores['total'] /= (ratings.count*3).to_f
			motorbike.update(totalRating: scores['total'], designRating: scores['design'], performanceRating: scores['performance'], comfortRating: scores['comfort'])
		else
			motorbike.update(totalRating: 0, designRating: 0, performanceRating: 0, comfortRating: 0)
		end
	end
	def updateBrandRating(brand)
		ratings = brand.brand_ratings
		if ratings.count > 0
			score = 0
			for rating in ratings do
				score += rating.rating
			end
			score /= ratings.count
			brand.update(rating: score)
		else
			brand.update(rating: 0)
		end
	end

	def bikeview
		@bike = findRecord(params[:bikeId], Motorbike)
		@mybikes = @bike.mybikes.limit(12)
	end

	def bestMotorbikes
		bestMotorbikes = Array.new
		motorbikeIds = MiscArchive.find_by(kind: 'best motorbikes')
		if motorbikeIds
			motorbikeIds = motorbikeIds.content.split('-')
			for i in 0..2
				motorbike = findRecord(motorbikeIds[i], Motorbike)
				if motorbike
					bestMotorbikes.push({id: motorbike.id, url: motorbike.url, year: motorbike.year, name: motorbike.name, displacement: motorbike.displacement, maxpower: motorbike.maxpower, maxtorque: motorbike.maxtorque, dry_weight: motorbike.dry_weight, price: motorbike.price, totalRating: motorbike.totalRating})
				end
			end
			render json: {result: true, bestMotorbikes: bestMotorbikes}
		else
			render json: {result: false}
		end
	end
	def bestTimelines
		bestTimelines = Array.new
		timelineIds = MiscArchive.find_by(kind: 'best timelines')
		if timelineIds
			timelineIds = timelineIds.content.split('-')
			for i in 0..2
				timeline = findRecord(timelineIds[i], Timeline)
				if timeline
					bestTimelines.push({id: timeline.id, title: timeline.title, category: timeline.category, desc: timeline.desc, viewCount: timeline.viewCount, commentCount: timeline.commentCount, likeCount: timeline.likeCount, userName: timeline.user.name, avatar_url: timeline.user.avatar, titleOfLevel: timeline.user.titleOfLevel, categoryColor: TimelineCategory.find_by(name: timeline.category).color, attachments: timeline.timeline_attachments, created_at: timeline.created_at})
				end
			end
			render json: {result: true, bestTimelines: bestTimelines}
		else
			render json: {result: false}
		end
	end

	def readMybikes
		motorbike = findRecord(params[:motorbikeId], Motorbike)
		if motorbike
			mybikes = motorbike.mybikes.order(subscribeCount: :asc).limit(params[:limit]).offset(params[:offset])
			if mybikes.count > 0
				mybikes2 = Array.new
				mybikes.each do |mybike|
					mybikes2.push({id: mybike.id, name: mybike.name, desc: mybike.desc, url: mybike.url, subscribeCount: mybike.subscribeCount, userName: mybike.user.name, titleOfLevel: mybike.user.titleOfLevel})
				end
				render json: {result: true, count: mybikes.count, mybikes: mybikes2}
			else
				render json: {result: true, count: 0}
			end
		else
			render json: {result: false, message: "can't find motorbike"}
		end
	end

	def checkBrandRating
		user = findUser(session[:user]['id'])
		if user
			rating = BrandRating.find_by(user: user, brand_id: params[:brandId])
			if rating
				render json: {result: true, rating: rating.rating, message: "exist rating"}
			else
				render json: {result: false, rating: nil, message: "you haven't rated this bike"}
			end
		else
			render json: {result: false, message: "cannot find user"}
		end
	end
	def rateBrand
		user = findUser(session[:user]['id'])
		if user
			brand = findRecord(params[:brandId], Brand)
			if brand
				brandRating = BrandRating.find_by(user: user, brand: brand)
				if brandRating
					brandRating.update(rating: params[:rating])
				else
					BrandRating.new(rating: params[:rating], user: user, brand: brand).save
				end
				updateBrandRating(brand)
				render json: {result: true, rating: brand.rating}
			else
				render json: {result: false, message: "존재하지 않는 브랜드입니다."}
			end
		else
			render json: {result: false, message: "존재하지 않는 계정입니다."}
		end
	end

	def checkBikeRating
		user = findUser(session[:user]['id'])
		if user
			rating = BikeRating.find_by(user: user, motorbike_id: params[:bikeId])
			if rating
				render json: {result: true, rating: rating, message: "exist rating"}
			else
				render json: {result: false, rating: nil, message: "you haven't rated this bike"}
			end
		else
			render json: {result: false, message: "cannot find user"}
		end
	end

	def reportMotorbike
		user = findUser(params[:userId])
		if user
			motorbike = findRecord(params[:bikeId], Motorbike)
			if motorbike
				report = MotorbikeReport.new(user: user, motorbike: motorbike, specName: params[:specName], content: params[:content], state: 1)
				if report.save
					render json: {result: true, message: 'success!'}
				else
					render json: {result: false, message: "cannot save report"}
				end
			else
				render json: {result: false, message: "cannot find bike"}
			end
		else
			render json: {result: false, message: "cannot find user"}
		end
	end

	def rateBike
		user = findUser(session[:user]['id'])
		if user
			motorbike = findRecord(params[:bikeId], Motorbike)
			if motorbike
				# userRating = BikeRating.where(user: user, motorbike: motorbike)
				userRating = BikeRating.find_by(user: user, motorbike: motorbike)
				if userRating
					userRating.update(design: params[:design], performance: params[:performance], comfort: params[:comfort])
				else
					BikeRating.new(user: user, motorbike: motorbike, design: params[:design], performance: params[:performance], comfort: params[:comfort]).save
					motorbike.update(ratingCount: motorbike.bike_ratings.count)
				end
				updateBikeRating(motorbike)
				render json: {result: true, rating: {total: motorbike.totalRating, design: motorbike.designRating, performance: motorbike.performanceRating, comfort: motorbike.comfortRating}, message: "success!!"}
			else
				render json: {result: false, message: "cannot find motorbike"}
			end
		else
			render json: {result: false, message: "cannot find user"}
		end
	end

	def searchbike
		@displacements = ["125cc 이하", "125~400cc", "400~600cc", "600~1000cc", "1000cc 이상"]
		@brands = Brand.all
		@styles = Style.all
		# @filterBikes = Motorbike.where(brand_id: "1", year: "2017")
		@filterBikes = nil
		@selectedStyleId = params.has_key?(:styleId) ? params[:styleId] : nil
	end

	def searchbikes
		# brandIds = Brand.where(name_kr: params[:selectedBrands]).pluck(:id)
		# styleIds = Style.where(name: params[:selectedStyles]).pluck(:id)
		# bikes = Motorbike.where(brand_id: brandIds, style_id: styleIds).pluck(:id, :name, :year, :displacement, :maxpower, :maxtorque, :weight, :price, :url)
		# render json: {result: true, key1: bikes, key2: styleIds}

		brands = Brand.where(name_kr: params[:selectedBrands])
		styles = Style.where(name: params[:selectedStyles])


		if params[:displacementRange].length > 0
			motorbikes = Motorbike.where(displacement: params[:displacementRange]['greater_than'].to_i..params[:displacementRange]['less_than'].to_i)
		end

		if params[:selectedYears].length > 0 and brands.count > 0 and styles.count > 0
			motorbikes = Motorbike.where(year: params[:selectedYears], brand: brands, style: styles)
		elsif params[:selectedYears].length > 0 and brands.count > 0
			motorbikes = Motorbike.where(year: params[:selectedYears], brand: brands)
		else
			motorbikes = Motorbike.where(brand: brands)
		end
		if params[:displacementRange].length > 0
			motorbikes = motorbikes.where(displacement: params[:displacementRange]['greater_than'].to_i..params[:displacementRange]['less_than'].to_i)
		end
		motorbikes = motorbikes.order(year: :desc)

		totalCount = params[:offset].to_i == 0 ? motorbikes.count : 0
		motorbikes = motorbikes.limit(params[:limit]).offset(params[:offset]).pluck(:id, :name, :year, :displacement, :maxpower, :maxtorque, :dry_weight, :price, :url, :ratingCount, :totalRating)
		render json: {result: true, bikes: motorbikes, totalCount: totalCount}
	end

	def readComments
		# 	params timelineId, offset, count
		motorbike = findRecord(params[:entityId], Motorbike)
		if motorbike
			bikeComments = motorbike.bike_comments.order(created_at: :asc).limit(params[:limit]).offset(params[:offset])
			unless bikeComments.empty?
				writers = Hash.new
				ratings = Hash.new
				replies = Hash.new
				bikeComments.each do|comment|
					writers[comment.id] = {'name' => comment.user.name, 'avatar_url' => comment.user.avatar, 'titleOfLevel' => comment.user.titleOfLevel}
					ratings[comment.id] = session[:logined] ? getMyRating('bikeComment', comment) : 0
					replies[comment.id] = comment.replyCount
				end
				render json: {result: true, message: 'success!!', commentCount: bikeComments.count, comments: bikeComments, writers: writers, ratings: ratings, replies: replies}
			else
				render json: {result: true, message: 'success but commentCount is Zero!!', commentCount: 0}
			end
		end
	end

	def rateComment
		user = findUser(params[:userId])
		if user
			bikeComment = findRecord(params[:commentId], BikeComment)
			if bikeComment
				rating = BikeCommentRating.find_by(user: user, bike_comment: bikeComment)
				if rating
					rating.update(rating: (rating.rating == 1) ? 0 : 1)
					likeCount = bikeComment.bike_comment_ratings.where(rating: 1).count
					bikeComment.update(likeCount: likeCount)
					if rating.rating == 1 and user.id != bikeComment.user.id
						Notification.new(kind: 'new-like-bikeComment', content: bikeComment.content, fromRefId: user.id, toRefId: bikeComment.motorbike.id, user: bikeComment.user).save
					end
					render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
				else
					rating = BikeCommentRating.new(rating: 1, user: user, bike_comment: bikeComment)
					if rating.save
						likeCount = bikeComment.bike_comment_ratings.where(rating: 1).count
						bikeComment.update(likeCount: likeCount)
						if user.id != bikeComment.user.id
							Notification.new(kind: 'new-like-bikeComment', content: bikeComment.content, fromRefId: user.id, toRefId: bikeComment.motorbike.id, user: bikeComment.user).save
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
			if timeSinceLastActivity(user, 'bikeComment')
				motorbike = findRecord(params[:entityId], Motorbike)
				if motorbike
					comment = BikeComment.new(content: params[:content], user: user, motorbike: motorbike)
					if comment.save
						updateUserExp('comment', user)
						user.last_activity.update(kind: 'bikeComment', refId: comment.id)
						render json: {result: true, message: 'success!', comment: comment, user: user}
					else
						render json: {result: false, message: '데이터베이스에 저장할 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
					end
				else
					render json: {result: false, message: '바이크를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
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
			bikeComment = findRecord(params[:commentId], BikeComment)
			if bikeComment
				bikeComment.update(content: params[:content])
				render json: {result: true, content: bikeComment.content, message: 'success!'}
			else
				render json: {result: false, message: '해당 댓글을 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
			end
		else
			render json: {result: false, message: '유저를 찾을 수 없습니다. 새로고침 후 다시 시도해 주세요!'}
		end
	end
	def deleteComment
		logger.info('deleteComment')
		bikeComment = findRecord(params[:commentId], BikeComment)
		if bikeComment
			user = findUser(params[:userId])
			if user
				if bikeComment.user_id == user.id
					if bikeComment.replyCount > 0
						bikeComment.update(state: 2)#답글이 있을경우 존재유지
					else
						bikeComment.destroy
					end
					render json: {result: true, state: bikeComment.state}
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
		bikeComment = findRecord(params[:commentId], BikeComment)
		if user and bikeComment
			if BikeCommentReport.exists?(user: user, bike_comment: bikeComment)
				render json: {result: false, message: "이미 신고한 댓글 입니다."}
			else
				reportItem = ReportItem.find_by(content: params[:itemContent])
				if reportItem
					BikeCommentReport.new(user: user, bike_comment: bikeComment, report_item: reportItem, content: params[:content], state: 1).save
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
		bikeComment = findRecord(params[:commentId], BikeComment)
		if bikeComment
			bikeReplies = bikeComment.bike_replies.order(created_at: :asc).limit(params[:limit]).offset(params[:offset])
			if bikeReplies.count > 0
				writers = Hash.new
				ratings = Hash.new
				bikeReplies.each do|reply|
					writers[reply.id] = {'name' => reply.user.name, 'avatar_url' => reply.user.avatar, 'titleOfLevel' => reply.user.titleOfLevel}
					ratings[reply.id] = session[:logined] ? getMyRating('bikeReply', reply) : 0
				end
				last = bikeReplies.count < params[:limit].to_i ? true : false
				render json: {result: true, last: last, replies: bikeReplies, writers: writers, ratings: ratings}
			else
				render json: {result: false, last: true}
			end
		else
			render json: {result: false, message: '해당 댓글을 찾을 수 없습니다.'}
		end
	end
	def rateReply
		user = findUser(params[:userId])
		if user
			bikeReply = findRecord(params[:replyId], BikeReply)
			if bikeReply
				bikeReplyRating = BikeReplyRating.find_by(user: user, bike_reply: bikeReply)
				if bikeReplyRating
					bikeReplyRating.update(rating: (bikeReplyRating.rating == 1) ? 0 : 1)
					likeCount = bikeReply.bike_reply_ratings.where(rating: 1).count
					bikeReply.update(likeCount: likeCount)
					if bikeReply.rating == 1 and bikeReply.user.id != user.id
						Notification.new(kind: 'new-like-bikeReply', content: bikeReply.content, fromRefId: user.id, toRefId: bikeReply.bike_comment.motorbike.id, user: bikeReply.user).save
					end
					render json: {result: true, rating: bikeReplyRating, likeCount: likeCount, message: 'success!!'}
				else
					bikeReplyRating = BikeReplyRating.new(rating: 1, user: user, bike_reply: bikeReply)
					if bikeReplyRating.save
						likeCount = bikeReply.bike_reply_ratings.where(rating: 1).count
						bikeReply.update(likeCount: likeCount)
						if bikeReply.user.id != user.id
							Notification.new(kind: 'new-like-bikeReply', content: bikeReply.content, fromRefId: user.id, toRefId: bikeReply.bike_comment.motorbike.id, user: bikeReply.user).save
						end
						render json: {result: true, rating: bikeReplyRating, likeCount: likeCount, message: 'success!!'}
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
			if timeSinceLastActivity(user, 'bikeReply')
				bikeComment = findRecord(params[:commentId], BikeComment)
				if bikeComment
					bikeReply = BikeReply.new(content: params[:content], bike_comment: bikeComment, user: user)
					if bikeReply.save
						updateUserExp('reply', user)
						user.last_activity.update(kind: 'bikeReply', refId: bikeReply.id)
						bikeComment.update(replyCount: bikeComment.bike_replies.count)
						if bikeComment.user.id != user.id
							Notification.new(kind: 'new-reply-bikeComment', content: params[:content], fromRefId: bikeReply.id, toRefId: bikeComment.motorbike.id, user: bikeComment.user).save
						end
						writer = {'name' => user.name, 'avatar_url' => user.avatar, 'titleOfLevel' => user.titleOfLevel}
						render json: {result: true, message: 'success!', reply: bikeReply, writer: writer}
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
			bikeReply = findRecord(params[:replyId], BikeReply)
			if bikeReply
				bikeReply.update(content: params[:content])
				if bikeReply.save
					render json: {result: true, content: bikeReply.content, message: 'success!'}
				else
					render json: {result: false, content: bikeReply.content, message: 'cannot save reply!'}
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
			bikeReply = BikeReply.find_by(id: params[:replyId], user: user)
			if bikeReply
				bikeComment = bikeReply.bike_comment
				bikeReply.destroy
				bikeComment.update(replyCount: bikeComment.bike_replies.count)
				render json: {result: true, message: 'success!'}
			else
				render json: {result: false, message: 'cannot find reply!'}
			end
		end
	end
	def reportReply
		user = findUser(params[:userId])
		bikeReply = findRecord(params[:replyId], BikeReply)
		if user and bikeReply
			if BikeReplyReport.exists?(user: user, bike_reply: bikeReply)
				render json: {result: false, message: "이미 신고한 답글 입니다."}
			else
				reportItem = ReportItem.find_by(content: params[:itemContent])
				if reportItem
					BikeReplyReport.new(user: user, bike_reply: bikeReply, report_item: reportItem, content: params[:content], state: 1).save
					render json: {result: true, message: "성공적으로 신고 되었습니다."}
				else
					render json: {result: false, message: "리포트아이템을 찾을 수 없습니다."}
				end
			end
		else
			render json: {result: false, message: "답글을 찾일 수 없습니다."}
		end
	end

	def updateStyleImage
		style = findRecord(params[:styleId], Style)
		if style
			#style.update(icon: params[:icon])
			render json: {result: false, message: "successfully"}
		else
			render json: {result: false, message: "cannot find style"}
		end
	end

  def updateBrandImage
		brand = findRecord(params[:brandId], Brand)
		if brand
			brand.update(logo: params[:logo])
			render json: {result: true, message: "successfully"}
		else
			render json: {result: false, message: "cannot find brand"}
		end
	end

	def readBikeThumb
		motorbike = findRecord(params[:id], Motorbike)
		if motorbike
			render json: {result: true, message: "successfully", motorbikeId: motorbike.id}
		else
			render json: {result: false, message: "can't find bikeThumb"}
		end
	end

	def updateBikeThumb
		motorbike = findRecord(params[:id], Motorbike)
		if motorbike and params[:url]
			motorbike.update(url: params[:url])
			render json: {result: true, message: "successfully", url: motorbike.url}
		else
			render json: {result: false, message: "can't find bikeThumb"}
		end
	end
	def requestKakaoSearch
		url = URI(URI.encode('https://dapi.kakao.com/v2/search/' + params[:category] + '?query=' + params[:searchWord] + '&size=' + params[:limit] + '&page=' + params[:offset] + '&sort=' + params[:sort]))
		req = Net::HTTP::Get.new(url)
		req['Authorization'] = 'KakaoAK ' + ENV['kakao_rest_api_key']
		res = Net::HTTP.start(url.hostname, url.port, :use_ssl => url.scheme == 'https') {|http|
			http.request(req)
		}
		render json: {result: true, body: res.body.force_encoding('UTF-8')}
	end
	def getOpenGraph(url)
		data = Hash.new
		begin
		doc = Nokogiri::HTML.parse(RestClient.get(url).body.force_encoding('UTF-8'))
		rescue Errno::ECONNRESET
			return nil
		else
		doc.css('meta').each do |m|
			if m.attribute('property') and m.attribute('property').to_s.include? 'og:'
				data[m.attribute('property').to_s] = m.attribute('content').to_s
			end
		end
		return data
		end
	end
	def requestNaverSearch
		url = URI(URI.encode('https://openapi.naver.com/v1/search/' + params[:category] + '?query=' + params[:searchWord] + '&display=' + params[:limit] + '&start=' + params[:offset] + '&sort=' + params[:sort]))
		req = Net::HTTP::Get.new(url)
		req['X-Naver-Client-Id'] = ENV['naver_client_id']
		req['X-Naver-Client-Secret'] = ENV['naver_client_secret']
		res = Net::HTTP.start(url.hostname, url.port, :use_ssl => url.scheme == 'https') {|http|
			http.request(req)
		}
		body = JSON.parse(res.body.force_encoding('UTF-8'))
		# logger.info res.body
		items = Array.new
		body['items'].each do |item|
			logger.info 'title = ' + item['title'] + ', originallink = ' + item['originallink']
			if item['originallink'].length > 0
				og = getOpenGraph(item['originallink'])
				if og and og.has_key? 'og:image'
					items.push(og)
				end
			end
		end
		render json: {result: true, items: items}
	end

	def updateNewslinks(brand, searchWord)
		url = URI(URI.encode('https://openapi.naver.com/v1/search/news?query=' + searchWord + '&display=16&start=1&sort=sim'))
		req = Net::HTTP::Get.new(url)
		req['X-Naver-Client-Id'] = ENV['naver_client_id']
		req['X-Naver-Client-Secret'] = ENV['naver_client_secret']
		res = Net::HTTP.start(url.hostname, url.port, :use_ssl => url.scheme == 'https') {|http|
			http.request(req)
		}
		body = JSON.parse(res.body.force_encoding('UTF-8'))

		if brand.newslinks.length > 0
			brand.newslinks.each_with_index do |newslink, i|
				item = body['items'][i]
				if item['originallink'].length > 0
					og = getOpenGraph(item['originallink'])
					if og and og.has_key? 'og:image'
						newslink.update(title: item['title'], desc: item['description'], thumb: og['og:image'], url: item['originallink'])
					end
				end
			end
		else
			count=0
			body['items'].each do |item|
				if item['originallink'].length > 0
					og = getOpenGraph(item['originallink'])
					if og and og.has_key? 'og:image'
						Newslink.new(brand: brand, title: item['title'], desc: item['description'], thumb: og['og:image'], url: item['originallink']).save
						count += 1
						if count >= 12
							break
						end
					end
				end
			end
		end
	end
	def readNewslinks
		brand = findRecord(params[:brandId], Brand)
		if brand
			diff = (Time.zone.now - brand.newsUpdatedAt)/1.day
			if diff > 3 or brand.newslinks.length == 0
				updateNewslinks(brand, params[:searchWord])
				brand.update(newsUpdatedAt: Time.zone.now)
			end
			brand = findRecord(params[:brandId], Brand)
			render json: {result: true, newslinks: brand.newslinks}
		else
			render json: {result: false, message: '해당 브랜드를 찾을 수 없습니다'}
		end
	end
	def updateBikeyoutube(motorbike, items)
		if motorbike.bikeyoutubes.length > 0
			motorbike.bikeyoutubes.each_with_index do |bikeyoutube, index|
				if items[index]
					snippet = items[index]['snippet']
					bikeyoutube.update(title: snippet['title'], desc: snippet['description'], thumb: snippet['thumbnails']['medium']['url'], videoId: items[index]['id']['videoId'])
				end
			end
		else
			items.each do |item|
				snippet = item['snippet']
				Bikeyoutube.new(motorbike: motorbike, title: snippet['title'], desc: snippet['description'], thumb: snippet['thumbnails']['medium']['url'], videoId: item['id']['videoId']).save
			end
		end
	end
	def requestYoutubeSearch
		motorbike = findRecord(params[:bikeId], Motorbike)
		if motorbike
			diff = (Time.zone.now - motorbike.ytUpdatedAt)/1.day
			if diff > 3 or motorbike.bikeyoutubes.length == 0
				url = 'https://www.googleapis.com/youtube/v3/search?q=' + params[:searchWord] + '&order=' + params[:order] + '&part=snippet&type=video&maxResults=' + params[:limit] + '&videoDefinition=high&regionCode=KR&key=' + ENV['google_api_key']
				response = Net::HTTP.get_response(URI(URI.encode(url)))
				response = JSON.parse(response.body)
				updateBikeyoutube(motorbike, response['items'])
				motorbike.update(ytUpdatedAt: Time.zone.now)
				motorbike = findRecord(params[:bikeId], Motorbike)
			end
			render json: {result: true, youtubes: motorbike.bikeyoutubes}
		else
			render json: {result: false, message: '해당 바이크를 찾을 수 없습니다'}
		end
	end

	def readLivecast
		livecasts = Array.new
		if session[:logined]
			Livecast.where('onair == ? AND user_id != ?', true, session[:user]['id']).order(updated_at: :desc).each do |livecast|
				if user = livecast.user
					livecasts.push({id: livecast.id, title: livecast.title, category: livecast.category, url: livecast.url, poster: livecast.poster, avatar: user.avatar, name: user.name})
				end
			end
		else
			Livecast.where(onair: true).order(updated_at: :desc).each do |livecast|
				if user = livecast.user
					livecasts.push({id: livecast.id, title: livecast.title, category: livecast.category, url: livecast.url, poster: livecast.poster, avatar: user.avatar, name: user.name})
				end
			end
		end
		render json: {result: true, livecasts: livecasts}
	end

	def liveview
		if params.has_key?(:livecastId)
			@livecast = findRecord(params[:livecastId], Livecast)
			if session[:logined]
				cookies[:userId] = session[:user]['id']
			end
		else
		end
	end

end
