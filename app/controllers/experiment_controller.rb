class ExperimentController < ApplicationController
  def experimentBikes
    if session[:logined]
      if checkMasterAccount(session[:user]['account'])
        @brandId = params[:brandId]
        @brands = Brand.all
      else
        redirect_back fallback_location: "/"
      end
    else
      redirect_back fallback_location: "/"
    end
  end
  def MayIHelpYou
    # bikes = Motorbike.where(style_id: nil)
    # File.open('nostyles.yml', 'w') do
    # |file|
    #   bikes.each do |bike|
    #     file.puts(bike.id.to_s + ' ' + bike.year + ' ' + bike.name)
    #   end
    # end
    #
    # nostyles = File.open('nostyles.yml', 'r').read
    # nostyles.gsub!(/\r\n?/, "\n")
    # nostyles.each_line do |line|
    #   a = line.split(' ')
    #   bike = findRecord(a.first.to_i, Motorbike)
    #   if bike
    #     bike.update(style_id: a.last.to_i)
    #   end
    # end

    # match(/\d+[.]\d+/).to_s 문자열중에서 float만 얻어오기(소수점일경우)
    # match(/\d+/).to_s 문자열중에서 float만 얻어오기(정수일경우)
    # bike = Motorbike.find(87)
    # dd = bike.displacements.match(/\d+[.]\d+/).to_s
    # if bike.displacement == 0
    # 	displacement = bike.displacements.match(/\d+/).to_s
    # 	logger.info 'displacement is zero but '
    # 	logger.info displacement.to_f
    # end
    #
    #

    # if params[:model].eql? 'motorbikes'
    #   Motorbike.all.each do |motorbike|
    #     if motorbike.url
    #       if motorbike.url.length > 0
    #         url = motorbike.url.gsub(/bikesalon-d86d9/, 'bikesalon-d86d9.appspot.com')
    #         motorbike.update(url: url)
    #       else
    #         logger.info 'url.length <= 0 model = ' + motorbike.year + ' ' + motorbike.name
    #       end
    #     else
    #       logger.info 'url=nil id = ' + motorbike.id.to_s + '  model = ' + motorbike.year + ' ' + motorbike.name
    #     end
    #   end
    # elsif params[:model].eql? 'brands'
    #   Brand.all.each do |brand|
    #     logo = brand.logo.gsub(/bikesalon-d86d9/, 'bikesalon-d86d9.appspot.com')
    #     brand.update(logo: logo)
    #   end
    # elsif params[:model].eql? 'styles'
    #   Style.all.each do |style|
    #     icon = style.icon.gsub(/bikesalon-d86d9/, 'bikesalon-d86d9.appspot.com')
    #     style.update(icon: icon)
    #   end
    # elsif params[:model].eql? 'users'
    #   User.all.each do |user|
    #     if user.avatar.include? 'bikesalon-d86d9'
    #       avatar = user.avatar.gsub(/bikesalon-d86d9/, 'bikesalon-d86d9.appspot.com')
    #       user.update(avatar: avatar)
    #     end
    #   end
    # end
    #
    #
    # responseResult = deleteTimelineAttachments2('images/tt/', 'daldal')

    render json: {result: true, responseResult: responseResult, message: "may I help you successfully"}
  end

  def readIds
    models = Motorbike.where(year: params[:year], brand_id: params[:brandId])
    render json: {result: true, models: models}
  end

  def deleteMotorbikesFromIds
    ids = params[:ids]
    ids.each do |id|
      bike = findRecord(id, Motorbike)
      if bike and bike.url.nil?
        logger.info 'destroy ' + bike.id.to_s + ' ' + bike.name
        bike.destroy
      end
    end
    render json: {result: true, message: 'deleted successfully'}
  end

  def readYaml
    # ultimate = Rails.public_path
    # ultimate = YAML.load_file(Rails.public_path + params[:filename])
    filePath = Rails.root.join('public', params[:filename])
    if File.exists?(filePath)
      ultimate = YAML.load_file(filePath)
      models = Array.new
      ultimate.each do |key, value|
        models.push(value)
      end
      render json: {result: true, models: models}
    else
      render json: {result: false, message: "can't find " + params[:filename] + " file"}
    end
  end
  def updateMotorbikes
    specs = params[:models]
    specs.each do |key, value|
      bike = Motorbike.find(value['id'])
      bike.ignition_type = value['Ignition Type']
      bike.wheelbase = value['Wheelbase']
      bike.front_disk = value['Front Brakes Dimensions - Disc Dimensions']
      bike.camshaft = value['Camshaft Valvetrain Configuration']
      bike.frame_type = value['Frame type']
      bike.fueltank = value['Fuel Tank Capacity']
      bike.final_drive = value['Transmission type, final drive ratio']
      bike.dry_weight = value['Dry Weight']
      bike.compression_ratio = value['Compression Ratio']
      bike.maxpower = value['Maximum power - Output - Horsepower']
      bike.emissions = value['Emissions']
      bike.clutch = value['Clutch type']
      bike.rear_suspension_travel = value['Rear Suspension Travel']
      bike.front_brakes = value['Front brakes']
      bike.engine_type = value['Engine type - Number of cylinders']
      bike.cooling_system = value['Cooling system']
      bike.valves = value['Number of valves per cylinder']
      bike.gasmileage = value['Fuel Consumption - MPG - Economy - Efficiency']
      bike.displacement = value['Engine size - Displacement - Engine capacity']
      bike.rear_disk = value['Rear Brakes Dimensions - Disc Dimensions']
      bike.front_suspension_travel = value['Front Suspension Travel']
      bike.fuel_delivery_system = value['Fuel system']
      bike.exhaust_system = value['Exhaust system']
      bike.front_suspension = value['Front Suspension']
      bike.top_speed = value['Top Speed']
      bike.maxtorque = value['Maximum torque']
      bike.lubrication_system = value['Lubrication system']
      bike.rear_tyre = value['Rear Tyres - Rims dimensions']
      bike.reserve_fuel = value['Reserve Fuel Capacity']
      bike.seat_height = value['Seat Height']
      bike.height = value['Height']
      bike.width = value['Width']
      bike.curb_weight = value['Curb Weight (including fluids)']
      bike.rear_brakes = value['Rear brakes']
      bike.engine_details = value['Engine details']
      bike.rear_suspension = value['Rear Suspension']
      bike.length = value['Length']
      bike.co2_emissions = value['CO2 emissions']
      bike.front_tyre = value['Front Tyres - Rims dimensions']
      bike.bore_stroke = value['Bore x Stroke']
      bike.gearbox_type = value['Gearbox']
      bike.lights = value['Lights']
      bike.trail_size = value['Trail size']
      bike.ground_clearance = value['Ground Clearance']
      bike.instruments = value['Instruments']
      bike.fuel_type = '가솔린'
      bike.save
    end
    render json: {result: true, message: "updated motorbikes successfully"}
  end

  def readBikezModels
    files = Dir[params[:path]]
    files.each do |file|
      readBikezModel(file)
    end
    render json: {result: true, files: files}
  end

  # functions
  def readBikezModel(path)
    bikez = YAML.load_file(path)
    logger.info 'read bikez path = ' + path
    fileName = path[path.rindex('/')+1..path.rindex('.')-1].split('_')
    brand = Brand.find(fileName[2])
    logger.info 'finded brand = ' + brand.name
    newModelCount=0
    findModelCount=0
    bikez.each do |key, value|
      if key.include?('New')
        logger.info 'new model name = ' + value['Model']
        newModel = Motorbike.new(year: value['Year'], brand: brand, style_id: value['Category'], name: value['Model'])
        updateBikezModel(newModel, value)
        newModelCount += 1
      else
        modelId = key.gsub(/\D+/, '')# replace non-digit to ''
        model = Motorbike.find(modelId)
        logger.info 'find model name = ' + modelId.to_s + ', name = ' + model.name
        updateBikezModel(model, value)
        findModelCount += 1
      end
    end
    logger.info 'bikez item count = ' + bikez.count.to_s
    logger.info 'newModelCount = ' + newModelCount.to_s + ', findModelCount = ' + findModelCount.to_s
    logger.info 'total updated model count = ' + (newModelCount+findModelCount).to_s
  end

  def evaluateSpec(value)
    if value.nil?
      return '정보없음'
    else
      return value
    end
  end
  def removeBracket(value)
    if value.nil?
      return '정보없음'
    else
      value = value.gsub(/\ /, '')
      if value.include?('(')
        return value[0..value.index('(')-1]
      else
        return value
      end
    end
  end
  def replaceMaxPowerTorque(maxpower)
    if maxpower.nil?
      return '정보없음'
    else
      hp = maxpower[0..maxpower.index('(')-1]
      rpm = maxpower[maxpower.rindex(')')+1..maxpower.length-1]
      return (hp+rpm).gsub(/\ /, '').gsub('RPM', 'rpm').gsub('HP', 'hp').gsub('@', ' @ ')
    end
  end
  def calculateGasmileage(fuelConsumption)
    if fuelConsumption.nil?
      return '정보없음'
    else
      fuelConsumption = fuelConsumption.gsub(/\ /, '')
      litresPerKm = fuelConsumption[0..fuelConsumption.index('(')-1]
      fuelConsumption = litresPerKm.split('/')
      litres = fuelConsumption[0].gsub(/[a-z]/, '')
      km = fuelConsumption[1].gsub(/[a-z]/, '')
      gasmileage = km.to_f/litres.to_f
      return gasmileage.round(2).to_s + 'km/리터 (' + litresPerKm.gsub('litres', '리터') + ')'
    end
  end
  def updateBikezModel(bike, value, is_save=true)
    bike.price = evaluateSpec(value['Price'])
    msrp = bike.price.gsub(/\D+/, '')
    bike.msrp = msrp.length > 0 ? msrp.to_i : 0
    bike.ignition_type = evaluateSpec(value['Ignition Type'])
    bike.wheelbase = removeBracket(value['Wheelbase'])
    bike.front_disk = removeBracket(value['Front Brakes Dimensions - Disc Dimensions'])
    bike.camshaft = evaluateSpec(value['Camshaft Valvetrain Configuration'])
    bike.frame_type = evaluateSpec(value['Frame type'])
    bike.fueltank = removeBracket(value['Fuel Tank Capacity']).gsub('litres', '리터')
    bike.final_drive = evaluateSpec(value['Transmission type, final drive ratio'])
    bike.dry_weight = removeBracket(value['Dry Weight'])
    bike.compression_ratio = evaluateSpec(value['Compression Ratio'])
    bike.maxpower = replaceMaxPowerTorque(value['Maximum power - Output - Horsepower'])
    bike.emissions = evaluateSpec(value['Emissions'])
    bike.clutch = evaluateSpec(value['Clutch type'])
    bike.rear_suspension_travel = removeBracket(value['Rear Suspension Travel'])
    bike.front_brakes = evaluateSpec(value['Front brakes'])
    bike.engine_type = evaluateSpec(value['Engine type - Number of cylinders'])
    bike.cooling_system = evaluateSpec(value['Cooling system'])
    bike.valves = evaluateSpec(value['Number of valves per cylinder'])
    bike.gasmileage = calculateGasmileage(value['Fuel Consumption - MPG - Economy - Efficiency'])
    bike.displacement = removeBracket(value['Engine size - Displacement - Engine capacity'])
    bike.rear_disk = removeBracket(value['Rear Brakes Dimensions - Disc Dimensions'])
    bike.front_suspension_travel = removeBracket(value['Front Suspension Travel'])
    bike.fuel_delivery_system = evaluateSpec(value['Fuel system'])
    bike.exhaust_system = evaluateSpec(value['Exhaust system'])
    bike.front_suspension = evaluateSpec(value['Front Suspension'])
    bike.top_speed = removeBracket(value['Top Speed'])
    bike.maxtorque = replaceMaxPowerTorque(value['Maximum torque'])
    bike.lubrication_system = evaluateSpec(value['Lubrication system'])
    bike.rear_tyre = evaluateSpec(value['Rear Tyres - Rims dimensions'])
    bike.reserve_fuel = removeBracket(value['Reserve Fuel Capacity'])
    bike.seat_height = removeBracket(value['Seat Height'])
    bike.height = removeBracket(value['Height'])
    bike.width = removeBracket(value['Width'])
    bike.curb_weight = removeBracket(value['Curb Weight (including fluids)'])
    bike.rear_brakes = evaluateSpec(value['Rear brakes'])
    bike.engine_details = evaluateSpec(value['Engine details'])
    bike.rear_suspension = evaluateSpec(value['Rear Suspension'])
    bike.length = removeBracket(value['Length'])
    bike.co2_emissions = removeBracket(value['CO2 emissions'])
    bike.front_tyre = evaluateSpec(value['Front Tyres - Rims dimensions'])
    bike.bore_stroke = removeBracket(value['Bore x Stroke'])
    bike.gearbox_type = evaluateSpec(value['Gearbox'])
    bike.lights = evaluateSpec(value['Lights'])
    bike.trail_size = removeBracket(value['Trail size'])
    bike.ground_clearance = removeBracket(value['Ground Clearance'])
    bike.instruments = evaluateSpec(value['Instruments'])
    bike.fuel_type = '가솔린'
    bike.totalRating = bike.totalRating.nil? ? 0 : bike.totalRating
    if is_save
      bike.save
    end
  end

  def findBikeThumb
    bike = findRecord(params[:bikeId], Motorbike)
    if bike
      render json: {result: true, bikeId: bike.id, url: bike.url}
    else
      render json: {result: false}
    end
  end

  #ReportView
  def reportView
    unless checkMasterAccount(session[:user]['account'])
      redirect_back fallback_location: "/"
    end
  end
  def getState(state)
    if state == 1
      return '접수'
    elsif state == 2
      return '보류'
    elsif state == 3
      return '완료'
    else
      return 'unknown'
    end
  end
  def getDestinationFrom(raw)
    if raw.class == TimelineReport
      return {timelineId: raw.timeline.id, timelineTitle: raw.timeline.title, userId: raw.timeline.user.id}
    elsif raw.class == CommentReport
      comment = raw.comment
      timeline = comment.timeline
      return {timelineId: timeline.id, timelineTitle: timeline.title, content: comment.content, userName: comment.user.name, userId: comment.user.id}
    elsif raw.class == ReplyReport
      reply = raw.reply
      timeline = reply.comment.timeline
      return {timelineId: timeline.id, timelineTitle: timeline.title, content: reply.content, userName: reply.user.name, userId: reply.user.id}
    elsif raw.class == BikeCommentReport
      bikeComment = raw.bike_comment
      return {url: '/main/bikeview?bikeId=' + bikeComment.motorbike.id.to_s, content: bikeComment.content, userName: bikeComment.user.name, userId: bikeComment.user.id}
    elsif raw.class == BikeReplyReport
      bikeReply = raw.bike_reply
      return {url: '/main/bikeview?bikeId=' + bikeReply.bike_comment.motorbike.id.to_s, content: bikeReply.content, userName: bikeReply.user.name, userId: bikeReply.user.id}
    elsif raw.class == ComparisonCommentReport
      comparisonComment = raw.comparison_comment
      return {bikeIds: comparisonComment.bike_comparison.bikeIds, content: comparisonComment.content, userName: comparisonComment.user.name, userId: comparisonComment.user.id}
    elsif raw.class == ComparisonReplyReport
      comparisonReply = raw.comparison_reply
      return {bikeIds: comparisonReply.comparison_comment.bike_comparison.bikeIds, content: comparisonReply.content, userName: comparisonReply.user.name, userId: comparisonReply.user.id}
    end
  end
  def readReports
    raws = nil
    if params[:reportKind].eql? 'timeline'
      raws = TimelineReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    elsif params[:reportKind].eql? 'comment'
      raws = CommentReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    elsif params[:reportKind].eql? 'reply'
      raws = ReplyReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    elsif params[:reportKind].eql? 'bikeComment'
      raws = BikeCommentReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    elsif params[:reportKind].eql? 'bikeReply'
      raws = BikeReplyReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    elsif params[:reportKind].eql? 'comparisonComment'
      raws = ComparisonCommentReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    elsif params[:reportKind].eql? 'comparisonReply'
      raws = ComparisonReplyReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    end
    if raws and raws.count > 0
      reports = Array.new
      raws.each do |raw|
        reports.push({id: raw.id, category: raw.report_item.content, content: raw.content, reporter: raw.user.name, destination: getDestinationFrom(raw), state: getState(raw.state), warned: raw.warned})
      end
      render json: {result: true, reports: reports}
    else
      render json: {result: false}
    end
  end
  def findReport(reportKind)
    report = nil
    if reportKind.eql? 'timeline'
      report = findRecord(params[:reportId], TimelineReport)
    elsif reportKind.eql? 'comment'
      report = findRecord(params[:reportId], CommentReport)
    elsif reportKind.eql? 'reply'
      report = findRecord(params[:reportId], ReplyReport)
    elsif reportKind.eql? 'bikeComment'
      report = findRecord(params[:reportId], BikeCommentReport)
    elsif reportKind.eql? 'bikeReply'
      report = findRecord(params[:reportId], BikeReplyReport)
    elsif reportKind.eql? 'comparisonComment'
      report = findRecord(params[:reportId], ComparisonCommentReport)
    elsif reportKind.eql? 'comparisonReply'
      report = findRecord(params[:reportId], ComparisonReplyReport)
    elsif reportKind.eql? 'motorbike'
      report = findRecord(params[:reportId], MotorbikeReport)
    end
    return report
  end
  def updateReportState
    report = findReport(params[:reportKind])
    if report
      report.update(state: params[:state].to_i)
      render json: {result: true}
    else
      render json: {result: false}
    end
  end

  def warningToUser
    report = findReport(params[:reportKind])
    user = findUser(params[:userId])
    if report and user
      user.update(warningCount: user.warningCount+1)
      mailer_response = UserMailer.warning(user, params[:category], params[:content]).deliver
      report.update(warned: true)
      if user.state.eql? 'normal'
        if user.warningCount >= ENV['user_max_warning'].to_i
          user.update(state: 'suspended')
          UserMailer.suspend(user).deliver
        end
      end
      render json: {result: true, response: mailer_response, message: 'sent email successfully!'}
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def deleteReport
    report = findReport(params[:reportKind])
    if report
      report.destroy
      render json: {result: true}
    else
      render json: {result: false}
    end
  end

  def editMotorbike
    unless checkMasterAccount(session[:user]['account'])
      redirect_back fallback_location: "/"
    end
    @motorbikeId = params[:motorbikeId]
  end
  def findMotorbike
    motorbike = findRecord(params[:motorbikeId], Motorbike)
    if motorbike
      render json: {result: true, motorbike: motorbike, brand: motorbike.brand.name_kr, style: motorbike.style.name}
    else
      render json: {result: false}
    end
  end
  def updateMotorbike(specs, motorbike)
    motorbike.name = specs['name']
    motorbike.price = specs['price']
    msrp = motorbike.price.gsub(/\D+/, '')
    motorbike.msrp = msrp.length > 0 ? msrp.to_i : 0
    displacement = specs['displacement'].to_f
    motorbike.displacement = displacement > 0 ? displacement : 0
    motorbike.compression_ratio = specs['compression_ratio']
    motorbike.maxpower = specs['maxpower']
    motorbike.maxtorque = specs['maxtorque']
    motorbike.engine_type = specs['engine_type']
    motorbike.engine_details = specs['engine_details']
    motorbike.bore_stroke = specs['bore_stroke']
    motorbike.valves = specs['valves']
    motorbike.fuel_delivery_system = specs['fuel_delivery_system']
    motorbike.fuel_type = specs['fuel_type']
    motorbike.ignition_type = specs['ignition_type']
    motorbike.camshaft = specs['camshaft']
    motorbike.cooling_system = specs['cooling_system']
    motorbike.lubrication_system = specs['lubrication_system']
    motorbike.gearbox_type = specs['gearbox_type']
    motorbike.final_drive = specs['final_drive']
    motorbike.clutch = specs['clutch']
    motorbike.exhaust_system = specs['exhaust_system']
    motorbike.front_brakes = specs['front_brakes']
    motorbike.front_disk = specs['front_disk']
    motorbike.rear_brakes = specs['rear_brakes']
    motorbike.rear_disk = specs['rear_disk']
    motorbike.front_tyre = specs['front_tyre']
    motorbike.rear_tyre = specs['rear_tyre']
    motorbike.front_suspension = specs['front_suspension']
    motorbike.rear_suspension = specs['rear_suspension']
    motorbike.front_suspension_travel = specs['front_suspension_travel']
    motorbike.rear_suspension_travel = specs['rear_suspension_travel']
    motorbike.dry_weight = specs['dry_weight']
    motorbike.curb_weight = specs['curb_weight']
    motorbike.length = specs['length']
    motorbike.width = specs['width']
    motorbike.height = specs['height']
    motorbike.trail_size = specs['trail_size']
    motorbike.wheelbase = specs['wheelbase']
    motorbike.seat_height = specs['seat_height']
    motorbike.fueltank = specs['fueltank']
    motorbike.reserve_fuel = specs['reserve_fuel']
    motorbike.frame_type = specs['frame_type']
    motorbike.ground_clearance = specs['ground_clearance']
    motorbike.top_speed = specs['top_speed']
    motorbike.gasmileage = specs['gasmileage']
    motorbike.co2_emissions = specs['co2_emissions']
    motorbike.emissions = specs['emissions']
    motorbike.lights = specs['lights']
    motorbike.instruments = specs['instruments']
  end
  def saveMotorbike
    specs = params[:specs]
    motorbike = findRecord(specs['id'], Motorbike)
    if motorbike
      updateMotorbike(specs, motorbike)
      if motorbike.save
        render json: {result: true, message: 'saved motorbike successfully'}
      else
        render json: {result: false, message: 'failed to save motorbike'}
      end
    else
      render json: {result: false, message: "can't find motorbike"}
    end
  end
  def createMotorbike
    if request.get?
      unless checkMasterAccount(session[:user]['account'])
        redirect_back fallback_location: "/"
      else
        @Brands = Brand.all
        @Styles = Style.all
      end
    elsif request.post?
      specs = params[:specs]
      motorbike = findRecord(specs['id'].to_i, Motorbike)
      unless motorbike
        brand = findRecord(specs['brand_id'], Brand)
        style = findRecord(specs['style_id'], Style)
        if brand and style
          motorbike = Motorbike.new(brand: brand, style: style)
          updateMotorbike(specs, motorbike)
          motorbike.update(year: specs['year'], totalRating: 0)
          if motorbike.save
            exportMotorbikeToYmlFile(motorbike.id)
            render json: {result: true, motorbikeId: motorbike.id, message: 'saved motorbike successfully'}
          else
            render json: {result: false, message: 'failed to save motorbike'}
          end
        else
          render json: {result: false, message: "can't find brand and style"}
        end
      else
        render json: {result: false, message: "Motorbike is already existed"}
      end
    end
  end

  def parseYmlString
    ymlRoot = YAML.load_stream(params[:yml])
    yml = ymlRoot.first
    values = yml[yml.keys.first]
    brand = Brand.where('lower(name) = ?', yml.keys.first.downcase).first
    style = findRecord(values['Category'], Style)
    if brand and style
      newModel = Motorbike.new(year: values['Year'], brand: brand, style: style, name: values['Model'])
      updateBikezModel(newModel, values, false)
      # render json: {result: true, motorbike: newModel, brand: newModel.brand.name_kr, style: newModel.style.name}
      render json: {result: true, motorbike: newModel}
    else
      render json: {result: false, message: '브랜드를 찾을 수 없습니다!'}
    end
  end
  def parseYml
    ymlRoot = YAML.load_stream(params[:yml])
    yml = ymlRoot.first
    values = yml[yml.keys.first]
    brand = findRecord(values['brand_id'], Brand)
    style = findRecord(values['style_id'], Style)
    if brand and style
      render json: {result: true, motorbike: values}
    else
      render json: {result: false, message: '브랜드를 찾을 수 없습니다!'}
    end
  end

  def motorbikeReportView
    unless checkMasterAccount(session[:user]['account'])
      redirect_back fallback_location: "/"
    end
  end
  def readMotorbikeReports
    raws = MotorbikeReport.order(updated_at: :desc).limit(params[:limit]).offset(params[:offset])
    if raws and raws.count > 0
      reports = Array.new
      raws.each do |raw|
        reports.push({id: raw.id, specName: raw.specName, content: raw.content, reporter: raw.user.account, state: getState(raw.state), motorbikeId: raw.motorbike.id})
      end
      render json: {result: true, reports: reports}
    else
      render json: {result: false}
    end
  end

  def confirmReflection
    @user = findUser(params[:userId])
  end
  def resetSuspend
    user = findUser(params[:userId])
    if user
      user.update(warningCount: 0, state: 'normal')
      render json: {result: true, message: "reset suspend"}
    else
      render json: {result: false}
    end
  end

  def saveYAMLFromModel
    if params[:model].eql? 'motorbikes'
      datas = Motorbike.all
    elsif params[:model].eql? 'brands'
      datas = Brand.all
    elsif params[:model].eql? 'styles'
      datas = Style.all
    elsif params[:model].eql? 'users'
      datas = User.all
    elsif params[:model].eql? 'sns_accounts'
      datas = SnsAccount.all
    elsif params[:model].eql? 'timeline_category'
      datas = TimelineCategory.all
    end
    # motorbike = findRecord(params[:motorbikeId], Motorbike)
    # motorbikes = Motorbike.where('id <= ?', 3)
    # motorbikes = Motorbike.all
    if datas.count > 0
      File.open(params[:model] + '.yml', 'w') do
        |file|
        datas.each do |data|
          file.puts('No' + data.id.to_s + ':')
          data.attributes.each do |key, value|
            unless key.eql? 'created_at' or key.eql? 'updated_at'
              file.puts('  ' + key + ': ' + value.to_s)
            end
          end
          file.puts('')
        end
      end
      render json: {result: true, message: 'success'}
    else
      render json: {result: false, message: 'failed'}
    end
  end
  def loadYAMLMotorbike
    yml = YAML.load_file('motorbikes.yml')
    yml.each do |key, value|
      logger.info key + ': ' + value.to_s
      logger.info value['name']
    end
    render json: {result: true, message: 'success'}
  end
  def exportMotorbikeToYmlFile(motorbikeId)
    motorbike = findRecord(motorbikeId, Motorbike)
    if motorbike
      File.open('public/createdMotorbikes/' + motorbike.year + '_' + motorbike.name + '.yml', 'w') do
      |file|
        file.puts(motorbike.brand.name + ':')
        motorbike.attributes.each do |key, value|
          unless key.eql? 'created_at' or key.eql? 'updated_at'
            file.puts('  ' + key + ': ' + value.to_s)
          end
        end
      end
    end
  end

  def findUserFromId
    user = findUser(params[:userId])
    if user
      render json: {result: true, account: user.account, name: user.name}
    else
      render json: {result: false}
    end
  end

  def emailToEveryone
    users = User.where.not(account: 'withdraw@bikesalon.kr')
    users.each do |user|
      UserMailer.shootMail(user, params[:subject], params[:content]).deliver
      sleep(0.35)
    end
    render json: {result: true}
  end

  def emailOneUser
    user = findUser(params[:userId])
    if user
      mailer_response = UserMailer.shootMail(user, params[:subject], params[:content]).deliver
      render json: {result: true, response: mailer_response}
    else
      render json: {result: false, message: "can't find user"}
    end
  end

  def getRecordInADay
    day = Time.zone.parse(params[:day] << ' 00:00:00')
    logger.info day
    logger.info day+1.day
    records = Array.new
    if params[:record].eql?('timeline')
      timelines = Timeline.where(created_at: day..(day + 1.day))
      timelines.each do |timeline|
        records.push({id: timeline.id, title: timeline.title, created_at: timeline.created_at, account: timeline.user.account})
      end
      # records = Timeline.where('created_at >= ? AND created_at <= ?', day, day+1.day)
    elsif params[:record].eql?('user')
      # records = User.where(created_at: day..(day + 1.day))
    end
    render json: {result: true, records: records}
  end

  def readLivecast
    livecasts = Array.new
    Livecast.where(onair: true).order(updated_at: :desc).each do |livecast|
      if user = livecast.user
        livecasts.push({title: livecast.title, category: livecast.category, url: livecast.url, avatar: user.avatar, name: user.name})
      end
    end
    render json: {result: true, livecasts: livecasts}
  end

end
