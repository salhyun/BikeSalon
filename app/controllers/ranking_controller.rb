class RankingController < ApplicationController
  def rankings
    archiveParams = [{kind: 'best motorbikes', interval: 3}, {kind: 'best brands', interval: 3}, {kind: 'best mybikes', interval: 2}, {kind: 'best timelines', interval: 1}]
    archiveParams.each do |archiveParam|
      updateMiscArchive(archiveParam[:kind], archiveParam[:interval])
    end

    @archives = Array.new
    archiveParams.each do |archiveParam|
      archive = MiscArchive.find_by(kind: archiveParam[:kind])
      @archives.push({kind: archive.kind, content: archive.content})
    end
  end

  def updateMiscArchive(kind, interval)
    archive = MiscArchive.find_by(kind: kind)
    if archive
      diff = (Time.zone.now - archive.updated_at)/1.day
      if diff > interval and archive.state.eql? 'updated'
        if kind.eql? 'best motorbikes'
          updateBestMotorbikes(archive)
        elsif kind.eql? 'best brands'
          updateBestBrands(archive)
        elsif kind.eql? 'best mybikes'
          updateBestMybikes(archive)
        elsif kind.eql? 'best timelines'
          updateBestTimelines(archive)
        end
      end
    else
      archive = MiscArchive.new(kind: kind, content: '')
      if archive.save
        if kind.eql? 'best motorbikes'
          updateBestMotorbikes(archive)
        elsif kind.eql? 'best brands'
          updateBestBrands(archive)
        elsif kind.eql? 'best mybikes'
          updateBestMybikes(archive)
        elsif kind.eql? 'best timelines'
          updateBestTimelines(archive)
        end
      end
    end
  end

  def updateBestMotorbikes(bestMotorbikes)
    bestMotorbikes.update(state: 'updating')
    ranking = Motorbike.order(totalRating: :desc).limit(10).pluck(:id)
    content = ranking.join('-')
    bestMotorbikes.update(content: content, state: 'updated')
  end
  def updateBestBrands(bestBrands)
    bestBrands.update(state: 'updating')
    ranking = Brand.order(rating: :desc).limit(10).pluck(:id)
    content = ranking.join('-')
    bestBrands.update(content: content, state: 'updated')
  end
  def updateBestMybikes(bestMybikes)
    bestMybikes.update(state: 'updating')
    ranking = Mybike.order(subscribeCount: :desc).limit(10).pluck(:id)
    content = ranking.join('-')
    bestMybikes.update(content: content, state: 'updated')
  end
  def updateBestTimelines(bestTimelines)
    bestTimelines.update(state: 'updating')
    ranking = Timeline.where(public: true).order(likeCount: :desc).limit(10).pluck(:id)
    content = ranking.join('-')
    bestTimelines.update(content: content, state: 'updated')
  end

  def parseRankingArchive(content, what='current')
    if what.eql? 'current'
      return content.split(',')[0]
    else
      return content.split(',')[1]
    end
  end

  def readBestMotorbikes
    ids = params[:content].split('-')
    motorbikes = Array.new
    ids.each do |id|
      motorbike = findRecord(id, Motorbike)
      if motorbike
        motorbikes.push({id: motorbike.id, year: motorbike.year, name: motorbike.name, totalRating: motorbike.totalRating})
      end
    end
    render json: {result: true, motorbikes: motorbikes}
  end
  def readBestBrands
    ids = params[:content].split('-')
    brands = Array.new
    ids.each do |id|
      brand = findRecord(id, Brand)
      if brand
        brands.push({id: brand.id, name: brand.name_kr, rating: brand.rating})
      end
    end
    render json: {result: true, brands: brands}
  end
  def readBestMybikes
    ids = params[:content].split('-')
    mybikes = Array.new
    ids.each do |id|
      mybike = findRecord(id, Mybike)
      if mybike
        mybikes.push({id: mybike.id, name: mybike.name, subscribeCount: mybike.subscribeCount})
      end
    end
    render json: {result: true, mybikes: mybikes}
  end
  def readBestTimelines
    ids = params[:content].split('-')
    timelines = Array.new
    ids.each do |id|
      timeline = findRecord(id, Timeline)
      if timeline
        timelines.push({id: timeline.id, title: timeline.title, likeCount: timeline.likeCount})
      end
    end
    render json: {result: true, timelines: timelines}
  end

end
