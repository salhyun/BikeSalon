class UserController < ApplicationController
	skip_before_filter :verify_authenticity_token

	def decodeJWT
		decoded_token = JWT.decode params[:token], nil, false
		render json: {result: true, decoded_token: decoded_token}
	end
	def sendResetPassword
		user = User.find_by(account: params[:email])
		if user
			if SnsAccount.exists?(user: user)
				render json: {result: false, message: "SNS 연동 계정은 비밀번호를 찾을 수 없습니다."}
			else
				user.update(secure_code: SecureRandom.hex(16))
				UserMailer.resetPassword(user).deliver
				render json: {result: true}
			end
		else
			render json: {result: false, message: "존재하지 않는 계정입니다."}
		end
	end
	def resendVerify
		user = User.find_by(account: params[:email])
		if user
			unless user.verified
				user.update(secure_code: SecureRandom.hex(16))
				UserMailer.verify(user).deliver
				render json: {result: true}
			else
				render json: {result: false, message: "이미 인증 되었습니다."}
			end
		else
			render json: {result: false, message: "존재하지 않는 계정입니다."}
		end
	end
	def checkAccount
		if User.exists?(account: params[:account])
			if params[:kind] and params[:uid]
				if SnsAccount.exists?(kind: params[:kind], uid: params[:uid])
					render json: {result: true, exist: ['email', 'sns']}
				else
					render json: {result: true, exist: ['email']}
				end
			else
				render json: {result: true, exist: ['email']}
			end
		else
			render json: {result: false}
		end
	end

	def create
		if User.exists?(account: params[:account])
			render json: {result: false, message: "이미 가입한 이메일 입니다."}
		else
			account = params[:account]
			password = Digest::SHA256.hexdigest(params[:password])
			nickname = (params[:nickname] == "") ? account.split('@')[0].gsub(/ /, '') : params[:nickname]
			# user = User.new(account: account, password: password, name: nickname, secure_code: SecureRandom.hex(16), state: 'normal', exp: 0, level: 0, titleOfLevel: '뉴비', maxCountMybike: 1, maxCountTimelinePhoto: 3)
			userLevelAttri = getUserLevelAttributes(0)
			user = User.new(account: account, password: password, name: nickname, verified: false, secure_code: SecureRandom.hex(16), state: 'normal', exp: 0, level: 0, titleOfLevel: '뉴비', maxCountMybike: userLevelAttri[:maxCountMybike], maxCountTimelinePhoto: userLevelAttri[:maxCountTimelinePhoto], maxSizeTimelineVideo: userLevelAttri[:maxSizeTimelineVideo])
			if user.save
				LastActivity.new(user: user, refId: user.id, kind: 'user').save
				UserMailer.welcome(user).deliver
				render json: {result: true, email: user.account}
			else
				render json: {result: false, message: "데이터베이스를 사용할 수 없습니다."}
			end
		end
	end
	def createWithSNS
		if SnsAccount.exists?(kind: params[:kind], uid: params[:uid])
			render json: {result: false, how: 'existed', message: "Account already exists."}
		elsif User.exists?(account: params[:email]) #계정 통합하기
			user = User.find_by(account: params[:email])
			snsAccount = SnsAccount.new(kind: params[:kind], uid: params[:uid], user: user)
			if snsAccount.save
				user.update(name: params[:nickname], avatar: params[:avatar])
				render json: {result: true, how: 'merge', message: "account merged successfully"}
			else
				render json: {result: false, how: 'merge', message: "account merging failed"}
			end
		else
			account = params[:email]
			password = Digest::SHA256.hexdigest(params[:uid])
			nickname = (params[:nickname] == "") ? account.split('@')[0] : params[:nickname]
			# user = User.new(account: account, password: password, name: nickname, avatar: params[:avatar], verified: false, secure_code: SecureRandom.hex(16), state: 'normal', exp: 0, level: 0, titleOfLevel: '뉴비', maxCountMybike: 1, maxCountTimelinePhoto: 3)
			userLevelAttri = getUserLevelAttributes(0)
			user = User.new(account: account, password: password, name: nickname, avatar: params[:avatar], verified: false, secure_code: SecureRandom.hex(16), state: 'normal', exp: 0, level: 0, titleOfLevel: '뉴비', maxCountMybike: userLevelAttri[:maxCountMybike], maxCountTimelinePhoto: userLevelAttri[:maxCountTimelinePhoto], maxSizeTimelineVideo: userLevelAttri[:maxSizeTimelineVideo])
			if user.save
				snsAccount = SnsAccount.new(kind: params[:kind], uid: params[:uid], user: user)
				if snsAccount.save
					LastActivity.new(user: user, refId: user.id, kind: 'user').save
					UserMailer.welcome(user.account).deliver
					# UserMailer.verify(user).deliver
					render json: {result: true, how: 'new', message: "account created successfully!"}
				else
					render json: {result: false, message: "It can't connect database"}
				end
			else
				render json: {result: false, message: "can't create account"}
			end
		end
	end

	def find
		account = params[:account]
		password = Digest::SHA256.hexdigest(params[:password])
		user = User.where(account: account, password: password)
		if user.count == 1
			session[:logined] = true
			session[:user] = user[0]
			render json: {key1: user.count, key2: user[0].account}
		else
			render json: {key1: user.count, key2: "what's wrong?"}
		end
	end
	
	def login
		if request.post?
			if User.exists?(account: params[:account])
				user = User.find_by(account: params[:account], password: Digest::SHA256.hexdigest(params[:password]))
				if user
					if user.verified
						calculateLevel(user)
						session[:logined] = true
						session[:user] = user
						render json: {result: true, account: user.account, name: user.name, avatar: user.avatar}
					else
						render json: {result: false, message: "이메일 인증이 되지 않았습니다. 이메일 인증을 해주세요!"}
					end
				else
					render json: {result: false, message: "잘못된 이메일 혹은 비밀번호 입니다!"}
				end
			else
				render json: {result: false, message: "잘못된 이메일 혹은 비밀번호 입니다!"}
			end
		end
	end
	def loginWithSNS
		# user = checkSNSAccount(params[:kind], params[:token])
		snsAccount = SnsAccount.find_by(kind: params[:kind], uid: params[:uid])
		if snsAccount
			user = snsAccount.user
			if user.verified
				calculateLevel(user)
				session[:logined] = true
				session[:user] = user
				render json: {result: true, account: user.account, name: user.name, avatar: user.avatar}
			else
				render json: {result: false, message: "이메일 인증이 되지 않았습니다. 이메일 인증을 해주세요!"}
			end
		else
			render json: {result: false, message: "존재 하지 않는 계정입니다!"}
		end
	end
	
	def logout
		reset_session
		redirect_to controller: :main, action: :view
	end
	
	def updateAvatarUrl
		user = findUser(params[:userId])
		if user
			user.update(avatar: params[:avatarUrl])
			if user.save
				session[:user]['avatar'] = user.avatar
				render json: {result: true, avatar: user.avatar}
			else
				render json: {result: false, message: "can't save avatar"}
			end
		else
			render json: {result: false, message: "can't find account"}
		end
	end
	
	def changeName
		user = findUser(params[:userId])
		if user
			user.update(name: params[:newName])
			session[:user] = user
			render json: {result: true, message: 'success!!', name: session[:user]['name']}
		else
			render json: {result: false, message: "can't find user"}
		end
	end

	def changePassword
		user = findUser(params[:userId])
		if user
			password = Digest::SHA256.hexdigest(params[:newPassword])
			user.update(password: password)
			session[:user] = user
			render json: {result: true, message: 'success!!'}
		else
			render json: {result: false, message: "can't find user"}
		end
	end
	def resetPassword
		if request.get?
			@validAccess = false
			user = findUser(params[:userId])
			if user
				if user.secure_code and user.secure_code == params[:secure_code]
					@validAccess = true
				end
			else
				@message = '유저를 찾을 수 없습니다.'
			end
		elsif request.post?
			user = findUser(params[:userId])
			if user
				user.update(password: Digest::SHA256.hexdigest(params[:newPassword]), secure_code: nil)
				render json: {result: true, message: "password updated successfully!"}
			else
				render json: {result: false, message: "can't find account"}
			end
		end
	end
	def verify
		@verify = false
		@message = ''
		user = findUser(params[:userId])
		if user
			if user.secure_code == params[:secure_code]
				if user.verified == false
					user.update(verified: true, secure_code: nil)
					@verify = user.verified
					@message = '인증이 정상적으로 처리 되었습니다.'
				else
					@message = '이미 인증되었습니다.'
				end
			else
				@message = '잘못된 인증 코드입니다.'
			end
		else
			@message = '존재하지 않는 계정입니다.'
		end
	end

	def createMybike
		user = findUser(params[:userId])
		motorbike = findRecord(params[:motorbikeId], Motorbike)
		if user and motorbike
			mybike = Mybike.new(name: params[:name], desc: params[:desc], public: params[:public], motorbike: motorbike, url: nil, thumb: nil, user: user)
			if mybike.save
				updateUserExp('mybike', user)
				user.last_activity.update(kind: 'mybike', refId: mybike.id)
				render json: {result: true, mybike: mybike}
			else
				render json: {result: false, message: "can't save to database"}
			end
		else
			render json: {result: false, message: "can't find user or motorbike"}
		end
	end

	def modifyMybike
    user = findUser(params[:userId])
    if user
			mybike = Mybike.find_by(id: params[:bikeId], user: user)
			if mybike
				mybike.name = params[:name]
				mybike.desc = params[:desc]
				public = params[:public] == 'true' ? true : false
				if mybike.public != public
					mybike.public = public
					mybike.timelines.each do |timeline|
						timeline.update(public: public)
					end
				end
				if Motorbike.exists?(id: params[:motorbikeId])
					mybike.motorbike_id = params[:motorbikeId].to_i
				end
				if mybike.save
					motorbike = {brandId: mybike.motorbike.brand.id, styleId: mybike.motorbike.style_id, modelId: mybike.motorbike.id, userId: mybike.user.id}
					render json: {result: true, mybike: mybike, motorbike: motorbike, message: 'finished modify!!'}
				else
					render json: {result: false, message: 'cannot save Mybike'}
				end
			else
				render json: {result: false, message: 'cannot find Mybike'}
			end
    else
      render json: {result: false, message: 'failed!!'}
    end
	end

	def deleteMybike
		logger.info(Rainbow("controller deleteMybike").yellow)
		user = findUser(params[:userId])
		if user
			mybike = Mybike.find_by(id: params[:bikeId], user: user)
			if mybike
				if mybike.timelines.count > 0
					mybike.timelines.each do |timeline|
						deleteAllHashtags(timeline)
					end
				end
				path = params[:firebaseUsersPath] + params[:firebaseUid] + '/' + mybike.id.to_s + '/'
				requestHttp(ENV['gcfHost'] + 'deletePath?path=' + path)
				mybike.destroy
				render json: {result: true, message: 'success!!'}
			else
				render json: {result: false, message: 'cannot delete Mybike!!'}
			end
		else
			render json: {result: false, message: 'failed!!'}
		end
	end

	def mybike
		user = findUser(session[:user]['id'])
		if user
			@mybikes = user.mybikes
			@mySubscribes = user.subscribe_mybikes.order(updated_at: :desc)
			@totalNotificationCount = user.notifications.count
		else
			redirect_to :back
		end
	end

	def parseNotification(notification)
		kinds = notification.kind.split('-')
		if kinds[0] == 'new'
			if kinds[1] == 'timeline'
				return nil
			elsif kinds[1] == 'comment' and kinds[2] == 'timeline'
				comment = findRecord(notification.fromRefId, Comment)
				timeline = findRecord(notification.toRefId, Timeline)
				if comment and comment.user and timeline
					return {id: notification.id, reference: 'timeline-' + timeline.id.to_s, kind: notification.kind, player: comment.user.name, content: notification.content}
				end
			elsif kinds[1] == 'reply'
				if kinds[2] == 'comment'
					reply = findRecord(notification.fromRefId, Reply)
					comment = findRecord(notification.toRefId, Comment)
					if reply and reply.user and comment and comment.timeline
						return {id: notification.id, reference: 'timeline-' + comment.timeline.id.to_s, kind: notification.kind, player: reply.user.name, content: notification.content}
					end
				elsif kinds[2] == 'bikeComment'
					bikeReply = findRecord(notification.fromRefId, BikeReply)
					motorbike = findRecord(notification.toRefId, Motorbike)
					if bikeReply and bikeReply.user and motorbike
						return {id: notification.id, reference: 'motorbike-' + motorbike.id.to_s, kind: notification.kind, player: bikeReply.user.name, content: notification.content}
					end
				elsif kinds[2] == 'comparisonComment'
					comparisonReply = findRecord(notification.fromRefId, ComparisonReply)
					bikeComparison = findRecord(notification.toRefId, BikeComparison)
					if comparisonReply and comparisonReply.user and bikeComparison
						return {id: notification.id, reference: 'bikeComparison-' + bikeComparison.id.to_s, kind: notification.kind, player: comparisonReply.user.name, content: notification.content}
					end
				end
			elsif kinds[1] == 'like'
				if kinds[2] == 'comparisonComment' or kinds[2] == 'comparisonReply'
					user = findUser(notification.fromRefId)
					bikeComparison = findRecord(notification.toRefId, BikeComparison)
					if user and bikeComparison
						return {id: notification.id, reference: 'bikeComparison-' + bikeComparison.id.to_s, kind: notification.kind, player: user.name, content: notification.content}
					end
				else #(kinds[2] == 'timeline' or kinds[2] == 'comment' or kinds[2] == 'reply')
					user = findUser(notification.fromRefId)
					timeline = findRecord(notification.toRefId, Timeline)
					if user and timeline
						return {id: notification.id, reference: 'timeline-' + timeline.id.to_s, kind: notification.kind, player: user.name, content: notification.content}
					end
				end
			elsif kinds[1] == 'subscribe' and kinds[2] == 'mybike'
				user = findUser(notification.fromRefId)
				mybike = findRecord(notification.toRefId, Mybike)
				if user and mybike
					return {id: notification.id, reference: 'mybike-' + mybike.id.to_s, kind: notification.kind, player: user.name, content: notification.content}
				end
			end
			return nil
		elsif kinds[0] == 'update'
			if kinds[1] == 'levelup' and kinds[2] == 'user'
				user = findUser(notification.toRefId)
				if user
					return {id: notification.id, reference: 'myinfo', kind: notification.kind, player: '', content: notification.content}
				end
			end
		end
		return nil
	end
	def readNotifications
		user = findUser(params[:userId])
		if user
			deleteCount=0
			userNotifications = user.notifications.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
			notifications = Array.new
			userNotifications.each do |notification|
				result = parseNotification(notification)
				if result
					notifications.push(result)
				else
					notification.destroy
					deleteCount += 1
				end
			end
			render json: {result: true, notifications: notifications, deleteCount: deleteCount}
		else
			render json: {result: false, message: "해당 유저를 찾을 수 없습니다"}
		end
	end
	def deleteNotification
		user = findUser(params[:userId])
		if user
			notification = Notification.find_by(id: params[:notificationId], user: user)
			if notification
				notification.destroy
				render json: {result: true, message: 'deleted notification'}
			else
				render json: {result: false, message: "can't find notification"}
			end
		else
			render json: {result: false, message: "can't find user"}
		end
	end


	def readMySubscribes
		user = findUser(params[:userId])
		if user
			subscribeMybikes = user.subscribe_mybikes.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
			mySubscribes = Array.new
			subscribeMybikes.each do |subscribeMybike|
				mybike = subscribeMybike.mybike
				mySubscribes.push({bikeId: mybike.id, url: mybike.url, name: mybike.name, desc: mybike.desc, userName: mybike.user.name, userAvatar: mybike.user.avatar, titleOfLevel: mybike.user.titleOfLevel, subscribeCount: mybike.subscribeCount, readTimelineCount: subscribeMybike.readTimelineCount, timelineCount: mybike.timelineCount})
			end
			render json: {result: true, mySubscribes: mySubscribes}
		else
			render json: {result: false, message: "해당 유저를 찾을 수 없습니다."}
		end
	end

	def updateTimelineAttachments
		timeline = findRecord(params[:timelineId], Timeline)
		if timeline
			params[:attachments].each do |index|
				attachment = params[:attachments][index]
				TimelineAttachment.new(timeline: timeline, kind: attachment['kind'], name: attachment['name'], original: attachment['original'], thumb: attachment['thumb']).save
			end
			render json: {result: true, attachments: timeline.timeline_attachments, message: 'success!!'}
		else
			render json: {result: false, message: "타임라인을 찾을 수 없습니다."}
		end
	end
	def createTimelineLocation(timeline, location)
		timelineLocation = TimelineLocation.new(timeline: timeline, lat: location[:lat].to_f, lng: location[:lng].to_f, name: location[:name], address: location[:address], title: timeline.title, category: timeline.category, cachedHashtags: timeline.cachedHashtags)
		return timelineLocation.save
	end
	def createTimeline
		user = findUser(params[:userId])
		if user
			mybike = findRecord(params[:mybikeId], Mybike)
			if mybike
				timeline = Timeline.new(kind: params[:kind], category: params[:category], title: params[:title], desc: params[:desc], public: params[:public], mybike: mybike, viewCount: 0, user: user)
				if timeline.save
					if params.has_key?(:tagNames)
						params[:tagNames].each do |tagName|
							if Hashtag.exists?(word: tagName)
								hashtag = Hashtag.find_by(word: tagName)
								hashtag.update(useCount: hashtag.useCount+1)
								timeline.hashtags << hashtag
							else
								hashtag = Hashtag.new(word: tagName, searchCount: 0, useCount: 1)
								hashtag.save
								timeline.hashtags << hashtag
							end
						end
						cachedHashtags = ''
						timeline.hashtags.each do |hashtag|
							cachedHashtags += ' #' + hashtag.word
						end
						timeline.update(cachedHashtags: cachedHashtags[1..-1])
					end
					timelineLocation = params[:timelineLocation]
					if timelineLocation[:enable] == 'true'
						createTimelineLocation(timeline, timelineLocation)
					end
					misc = {'ratingNum' => timeline.likeCount,
									'commentNum' => timeline.commentCount,
									'timelineLocation' => timeline.timeline_location,
									'categoryColor' => TimelineCategory.find_by(name: timeline.category).color}
					mybike.update(timelineCount: mybike.timelines.count)
					updateUserExp('timeline', user)
					user.last_activity.update(kind: 'timeline', refId: timeline.id)
					render json: {result: true, timeline: timeline, misc: misc, message: 'success!!'}
				else
					render json: {result: false, message: "타임라인을 찾을 수 없습니다."}
				end
			else
				render json: {result: false, message: "내 바이크를 찾을 수 없습니다."}
			end
		else
			render json: {result: false, message: "유저를 찾을 수 없습니다."}
		end
	end
	def updateTimelineLocation(timeline, location)
		timeline.timeline_location.update(lat: location[:lat].to_f, lng: location[:lng].to_f, name: location[:name], address: location[:address], title: timeline.title, category: timeline.category, likeCount: timeline.likeCount, cachedHashtags: timeline.cachedHashtags)
	end
	def deleteAllHashtags(timeline)
		unless timeline.hashtags.empty?
			ids = timeline.hashtags.pluck(:id)
			ids.each do |id|
				hashtag = findRecord(id, Hashtag)
				if hashtag
					timeline.hashtags.delete hashtag
				end
			end
		end
	end
	def modifyTimeline
		user = findUser(params[:userId])
		if user
			timeline = Timeline.find_by(id: params[:timelineId], user: user)
			if timeline
				if params[:updateAttachments].eql? 'true'
					attachments = timeline.timeline_attachments
					if attachments.count > 0
						deleteTimelineAttachments(attachments, params[:firestoragePath])
					else
						deleteTimelineAttachments2(params[:firestoragePath], 'timeline-' + timeline.id.to_s + '-')
					end
				end
				cachedHashtags = ''
				deleteAllHashtags(timeline)
				if params.has_key?(:tagNames)
					params[:tagNames].each do |tagName|
						if Hashtag.exists?(word: tagName)
							unless timeline.hashtags.exists?(word: tagName)
								hashtag = Hashtag.find_by(word: tagName)
								hashtag.update(useCount: hashtag.useCount+1)
								timeline.hashtags << hashtag
							end
						else
							hashtag = Hashtag.new(word: tagName, searchCount: 0, useCount: 1)
							hashtag.save
							timeline.hashtags << hashtag
						end
					end
					timeline.hashtags.each do |hashtag|
						cachedHashtags += ' #' + hashtag.word
					end
					cachedHashtags = cachedHashtags[1..-1]
				end
				timeline.update(public: params[:public], kind: params[:kind], category: params[:category], title: params[:title], desc: params[:desc], cachedHashtags: cachedHashtags)
				timelineLocation = params[:timelineLocation]
				if timelineLocation[:enable] == 'true'
					if timeline.timeline_location.nil?
						createTimelineLocation(timeline, timelineLocation)
					else
						updateTimelineLocation(timeline, timelineLocation)
					end
					render json: {result: true, timeline: timeline, categoryColor: TimelineCategory.find_by(name: timeline.category).color, timelineLocation: timeline.timeline_location}
				else
					if timeline.timeline_location
						timeline.timeline_location.destroy
					end
					render json: {result: true, timeline: timeline, categoryColor: TimelineCategory.find_by(name: timeline.category).color, timelineLocation: nil}
				end
			else
				render json: {result: false, message: '타임라인을 찾을 수 없습니다.'}
			end
		else
			render json: {result: false, message: '유저를 찾을 수 없습니다.'}
		end
	end

	def deleteTimeline
		user = findUser(params[:userId])
		if user
			timeline = Timeline.find_by(user: user, id: params[:timelineId])
			mybike = timeline.mybike
			if timeline and mybike
				deleteAllHashtags(timeline)
				attachments = timeline.timeline_attachments
				if attachments.count > 0
					deleteTimelineAttachments(attachments, params[:firestoragePath])
				else
					deleteTimelineAttachments2(params[:firestoragePath], 'timeline-' + timeline.id.to_s + '-')
				end
				timeline.destroy
				mybike.update(timelineCount: mybike.timelines.count)
				render json: {result: true}
			else
				render json: {result: false, message: '타임라인을 찾을 수 없습니다.'}
			end
		else
			render json: {result: false, message: '유저를 찾을 수 없습니다.'}
		end
	end

	def findTimeline
		logger.info("controller findTimeline")
		timeline = findRecord(params[:id], Timeline)
		if timeline
			render json: {result: true, timeline: timeline}
		else
			render json: {result: false}
		end
	end

	def deleteTimelineAttachments(attachments, path)
		filenames = ''
		attachments.each do |attachment|
			filenames += attachment.name + ',' + attachment.name + '_thumb,'
			attachment.destroy
		end
		# filenames.delete_suffix!(',')
		filenames = filenames[0..-2]
		gcfunction = ENV['gcfHost'] + 'deleteFiles?'
		return requestHttp(gcfunction + 'path=' + path + '&filenames=' + filenames)
	end
	def deleteTimelineAttachments2(path, keyword)
		gcfunction = ENV['gcfHost'] + 'findFiles?'
		response = requestHttp(gcfunction + 'path=' + path + '&keyword=' + keyword)
		if response['result'] and response['fileNames'].length > 0
			filenames = response['fileNames'].join(',')
			gcfunction = ENV['gcfHost'] + 'deleteFiles?'
			response = requestHttp(gcfunction + 'path=' + path + '&filenames=' + filenames)
			return response['result']
		end
		return false
	end

	def requestHttp(uri, jsonParsing=true)
		uri = URI.parse(uri)
		response = Net::HTTP.get_response(uri)
		return jsonParsing ? JSON.parse(response.body) : response.body
	end

	def testHttp
		responses = Array.new
		host = ENV['gcfHost'] + 'helloWorld?'
		uri = host + 'path=' + params[:path]
		responses.push(requestHttp(uri))
		render json: {result: true, responses: responses}
	end

	def readTimelines
		currentBike = findRecord(params[:bikeId], Mybike)
		if currentBike
			timelines = []
			if params[:searchWord].length > 0
				# timelines = timelines.where("title like ? OR desc like ? OR category like ?", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%")
				if params[:searchWord][0] == '#'
					hashtag = Hashtag.all.find_by(word: params[:searchWord][1..-1])
					if hashtag
						if params[:offset] == '0'
							hashtag.update(searchCount: hashtag.searchCount+1)
						end
						timelines = hashtag.timelines.order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
					end
				else
					timelines = currentBike.timelines.where("title like ? OR category like ? OR cachedHashtags like ?", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%", "%#{params[:searchWord]}%").order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
				end
			else
				timelines = currentBike.timelines.order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
			end
			unless timelines.empty?
				misc = Hash.new
				timelines.each do|timeline|
					misc[timeline.id] = {'ratingNum' => timeline.likeCount,
															 'commentNum' => timeline.commentCount,
															 'categoryColor' => TimelineCategory.find_by(name: timeline.category).color,
															 'attachments' => timeline.timeline_attachments,
															 'timelineLocation' => timeline.timeline_location}
				end
				render json: {result: true, timelineCount: timelines.count, timelines: timelines, misc: misc}
			else
				render json: {result: true, message: '더 이상 타임라인이 없습니다.', timelineCount: timelines.count}
			end
		else
			render json: {result: false, message: "내 바이크를 찾을 수 없습니다."}
		end
	end

	def timeline
		@currentBike = findRecord(params[:bikeId], Mybike)
		if @currentBike
			@timelineCategories = TimelineCategory.all.order(id: :asc)

			@guest = true
			if session[:logined]
				@guest = (@currentBike.user.id == session[:user]['id']) ? false : true
				if @guest == true
					@isSubscribe = SubscribeMybike.exists?(user_id: session[:user]['id'], mybike_id: @currentBike.id)
					if @isSubscribe
						subscribeMybike = SubscribeMybike.find_by(user_id: session[:user]['id'], mybike_id: @currentBike.id)
						subscribeMybike.update(readTimelineCount: @currentBike.timelineCount)
					end
				end
			end
		else
			redirect_to '/'
		end
	end

	def rateTimeline
		user = findUser(session[:user]['id'])
		timeline = findRecord(params[:timelineId], Timeline)
		if timeline
			rating = TimelineRating.find_by(user: user, timeline: timeline)
			if rating
				rating.update(rating: (rating.rating == 1) ? 0 : 1)
				likeCount = timeline.timeline_ratings.where(rating: 1).count
				timeline.update(likeCount: likeCount)
				if timeline.timeline_location
					timeline.timeline_location.update(likeCount: likeCount)
				end
				render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
			else
				rating = TimelineRating.new(rating: 1, user: user, timeline: timeline)
				if rating.save
					likeCount = timeline.timeline_ratings.where(rating: 1).count
					timeline.update(likeCount: likeCount)
					if timeline.timeline_location
						timeline.timeline_location.update(likeCount: likeCount)
					end
					Notification.new(kind: 'new-like-timeline', content: '좋아요 표시', fromRefId: user.id, toRefId: timeline.id, user: timeline.user).save
					render json: {result: true, rating: rating, likeCount: likeCount, message: 'success!!'}
				else
					render json: {result: false , message: 'cannot save database!'}
				end
			end
		else
			render json: {result: false, message: 'cannot find timeline'}
		end
	end

	def subscribeMybike
		user = findUser(params[:userId])
		if user
			mybike = findRecord(params[:mybikeId], Mybike)
			if mybike
				subscribe = mybike.subscribe_mybikes.find_by(user: user)
				if subscribe
					subscribe.destroy
					subscribeCount = mybike.subscribe_mybikes.count
					mybike.update(subscribeCount: subscribeCount)
					render json: {result: true, subscribe: 0, subscribeCount: subscribeCount}
				else
					SubscribeMybike.new(user: user, mybike: mybike, readTimelineCount: mybike.timelineCount).save
					subscribeCount = mybike.subscribe_mybikes.count
					mybike.update(subscribeCount: subscribeCount)
					Notification.new(kind: 'new-subscribe-mybike', content: '구독', fromRefId: user.id, toRefId: mybike.id, user: mybike.user).save
					render json: {result: true, subscribe: 1, subscribeCount: subscribeCount}
				end
			else
				render json: {result: false, message: '내바이크를 찾을 수 없습니다.'}
			end
		else
			render json: {result: false, message: '해당유저를 찾을 수 없습니다.'}
		end
	end

	def reportTimeline
		user = findUser(params[:userId])
		timeline = findRecord(params[:timelineId], Timeline)
		if timeline and user
			if TimelineReport.exists?(user: user, timeline: timeline)
				render json: {result: false, message: "이미 신고한 타임라인 입니다."}
			else
				reportItem = ReportItem.find_by(content: params[:itemContent])
				if reportItem
					TimelineReport.new(user: user, timeline: timeline, report_item: reportItem, content: params[:content], state: 1).save
					render json: {result: true, message: "성공적으로 신고 되었습니다."}
				else
					render json: {result: false, message: "리포트아이템을 찾을 수 없습니다."}
				end
			end
		else
			render json: {result: false, message: "타임라인을 찾일 수 없습니다."}
		end
	end

	def photoview
		@currentUser = findUser(session[:user]['id'])
		@currentTimeline = findRecord(params[:id], Timeline)
		@currentBike = findRecord(@currentTimeline.mybike_id, Mybike)
		@rating = @currentTimeline.timeline_ratings
		@likeCount = @rating.where(rating: 1).count
	end

	def readBrands
		user = findUser(params[:userId])
		if user
			brands = Array.new
			Brand.all.each do |brand|
				brands.push({id: brand.id, name: brand.name_kr})
			end
			render json: {result: true, brands: brands}
		else
			render json: {result: false, message: "cannot find user"}
		end
	end
	def readStyles
		user = findUser(params[:userId])
		if user
			styles = Array.new
			Style.all.each do |style|
				styles.push({id: style.id, name: style.name})
			end
			render json: {result: true, styles: styles}
		else
			render json: {result: false, message: "cannot find user"}
		end
	end
	def readModels
		user = findUser(params[:userId])
		if user
			filteredModels = Array.new
			models = Motorbike.where(brand_id: params[:brandId], style_id: params[:styleId]).order(year: :desc)
			models.each do |model|
				filteredModels.push({id: model.id, name: model.year + ' ' + model.name})
			end
			render json: {result: true, models: filteredModels}
		else
			render json: {result: false, message: "cannot find user"}
		end
	end
	def updateMybikeUrl
		mybike = findRecord(params[:mybikeId], Mybike)
		if mybike
			mybike.update(url: params[:original], thumb: params[:thumb])
			render json: {result: true, mybike: mybike, motorbike: mybike.motorbike, message: "updated successfully"}
		else
			render json: {result: false, message: "cannot find mybike"}
		end
	end
	def readMybike
		mybike = findRecord(params[:mybikeId], Mybike)
		if mybike
			render json: {result: true, mybike: mybike}
		else
			render json: {result: false, message: "cannot find mybike"}
		end
	end
	def withdrawUser
		user = findUser(params[:userId])
		withdraw = User.find_by(account: 'withdraw@bikesalon.kr')
		if user and withdraw
			user.mybikes.each do |mybike|
				if mybike.timelines.count > 0
					mybike.timelines.each do |timeline|
						deleteAllHashtags(timeline)
					end
				end
				mybike.destroy
			end
			user.comments.each do |comment|
				comment.update(user: withdraw)
			end
			user.replies.each do |reply|
				reply.update(user: withdraw)
			end
			user.bike_comments.each do |bike_comment|
				bike_comment.update(user: withdraw)
			end
			user.bike_replies.each do |bike_reply|
				bike_reply.update(user: withdraw)
			end
			user.comparison_comments.each do |comparison_comment|
				comparison_comment.update(user: withdraw)
			end
			user.comparison_replies.each do |comparison_reply|
				comparison_reply.update(user: withdraw)
			end
			snsAccount = SnsAccount.find_by(user: user)
			if snsAccount
				snsAccount.destroy
			end
			path = params[:firebaseUsersPath] + params[:firebaseUid] + '/'
			requestHttp(ENV['gcfHost'] + 'deletePath?path=' + path)
			user.destroy
			reset_session
			render json: {result: true, message: "deleted user successfully!"}
		else
			render json: {result: false, message: "유저를 찾을 수 없습니다."}
		end
	end

	def failurelog
		Failurelog.new(kind: params[:kind], content: params[:content]).save
		render json: {result: true, message: "created log successfully!"}
	end
	def getUserLevelAttributes(level)
		state = {titleOfLevel: '전설', maxCountMybike: 50, maxCountTimelinePhoto: 30, maxSizeTimelineVideo: 50}
		if level < 1
			state = {titleOfLevel: '뉴비', maxCountMybike: 1, maxCountTimelinePhoto: 5, maxSizeTimelineVideo: 15}
		elsif level < 3
			state = {titleOfLevel: '초보', maxCountMybike: 3, maxCountTimelinePhoto: 10, maxSizeTimelineVideo: 20}
		elsif level < 6
			state = {titleOfLevel: '중수', maxCountMybike: 5, maxCountTimelinePhoto: 12, maxSizeTimelineVideo: 24}
		elsif level < 12
			state = {titleOfLevel: '고수', maxCountMybike: 10, maxCountTimelinePhoto: 14, maxSizeTimelineVideo: 28}
		elsif level < 36
			state = {titleOfLevel: '달인', maxCountMybike: 15, maxCountTimelinePhoto: 16, maxSizeTimelineVideo: 32}
		elsif level < 72
			state = {titleOfLevel: '대가', maxCountMybike: 20, maxCountTimelinePhoto: 18, maxSizeTimelineVideo: 34}
		elsif level < 144
			state = {titleOfLevel: '원로', maxCountMybike: 30, maxCountTimelinePhoto: 20, maxSizeTimelineVideo: 36}
		end
		return state
	end
	def calculateLevel(user)
		age = (Time.zone.now - user.created_at)/1.day
		level = age + user.exp
		user.update(level: level > 0 ? (level/30.41).floor : 0)
		userLevelAttri = getUserLevelAttributes(user.level)
		unless user.titleOfLevel.eql? userLevelAttri[:titleOfLevel]
			Notification.new(kind: 'update-levelup-user', content: user.titleOfLevel + '-' + userLevelAttri[:titleOfLevel] , fromRefId: user.id, toRefId: user.id, user: user).save
			user.update(titleOfLevel: userLevelAttri[:titleOfLevel], maxCountMybike: userLevelAttri[:maxCountMybike], maxCountTimelinePhoto: userLevelAttri[:maxCountTimelinePhoto], maxSizeTimelineVideo: userLevelAttri[:maxSizeTimelineVideo])
		end
	end

	def readAllUserLevelAttributes
		userLevelAttributes = Array.new
		levels = [0, 1, 3, 6, 12, 36, 72, 144]
		levels.each do |level|
			userLevelAttributes.push(getUserLevelAttributes(level))
		end
		render json: {result: true, userLevelAttributes: userLevelAttributes}
	end

	def sendProposeMail
		user = findUser(params[:userId])
		if user
			mailer_response = UserMailer.propose(user, params[:content]).deliver
			render json: {result: true, response: mailer_response, message: 'sent email successfully!'}
		else
			render json: {result: false, message: "can't find user"}
		end
	end
	def sendReflectionMail
		user = findUser(params[:userId])
		if user
			mailer_response = UserMailer.reflection(user, params[:content]).deliver
			render json: {result: true, response: mailer_response, message: 'sent email successfully!'}
		else
			render json: {result: false, message: "can't find user"}
		end
	end

	def sendTestMail
		mailer_response = UserMailer.welcome(params[:email]).deliver
		render json: {result: true, response: mailer_response, message: 'sent email successfully!'}
	end

	def getFirebasePassword
		if session[:logined] and User.exists?(account: params[:account])
			render json: {result: true, password: ENV['firebase_public_password']}
		else
			render json: {result: false}
		end
	end
	def getFirebaseConfig
		render json: {result: true, config: ENV['firebase_config']}
	end

	def mylivestudio
		if session[:logined] and User.exists?(id: session[:user]['id'])
			user = findUser(session[:user]['id'])
			if user
				if user.livecast
					@livecast = user.livecast
				else
					livecast = Livecast.new(user: user, category: params[:category], title: params[:title], onair: true, poster: '/poster.jpg')
					livecast.save
					streamkey = Digest::SHA256.hexdigest(user.id.to_s + livecast.id.to_s + user.account)
					streamkey = streamkey[0..7]
					url = ENV['hlsClient'] + streamkey + '.m3u8'
					livecast.update(streamkey: streamkey, url: url)
					@livecast = livecast
				end
				cookies[:userId] = user.id
			end
		else
			redirect_to '/'
		end
	end

	def startLivecast
		user = findRecord(params[:userId], User)
		if user
			if user.livecast
				user.livecast.update(category: params[:category], title: params[:title], onair: true)
				if params.has_key?(:poster)
					user.livecast.update(poster: params[:poster])
				end
			end
			user = findRecord(params[:userId], User)
			render json: {result: true, livecast: user.livecast}
		else
			render json: {result: false, message: '유저를 찾을 수 없습니다.'}
		end
	end
	def stopLivecast
		user = findRecord(params[:userId], User)
		if user and user.livecast.length > 0
			user.livecast.update(onair: false)
		else
			render json: {result: false, message: '유저를 찾을 수 없습니다.'}
		end
	end

end
