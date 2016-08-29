require 'simple-rss'
require 'open-uri'
require 'time'

class EpisodesController < ApplicationController
  before_action :set_episode, only: [:show, :edit, :update, :destroy]

  # GET /episodes
  # GET /episodes.json
  def index
    @episodes = Episode.all
  end

  def clear
    Episode.delete_all
    Shownote.delete_all
    redirect_to root_url
  end

  def updateFromRss

    SimpleRSS.item_tags << 'enclosure#url'
    SimpleRSS.item_tags << 'itunes:duration'
    rss = SimpleRSS.parse(open('http://feeds.rebuild.fm/rebuildfm'))

    noteURL = %r!&lt;li&gt;&lt;a href=&quot;.+!

    rss.items.each do |item|
      title = item.title.force_encoding('utf-8')

      # skip if already exist
      next if Episode.find_by( title: title)

      params = {title: title}

      m = title.match(/(\d+):/)
      params[:no] = m[1]

      params[:link] = item.link.force_encoding('utf-8')
      params[:description] = item[:description].force_encoding('utf-8')
      params[:pubDate] = item[:pubDate]
      params[:mp3] = item[:enclosure_url].force_encoding('utf-8')

      duration = item[:itunes_duration]
      if duration.count(':') == 1
        duration = "00:#{duration}"
      end
      params[:duration] = duration

      m = params[:description].match(%r!&lt;p&gt;(.+)&lt;/p&gt;!)
      params[:agenda] = m[1]

      @episode = Episode.new(params)
      @episode.shownotes = []

      note = item[:description].force_encoding('utf-8')
      list = params[:description].scan(%r!&lt;li&gt;&lt;a href=&quot;.+!)
      list.each do |note|
        url = note.match(/(http.+)&quot/)
        title = note.match(%r!&quot;&gt;(.+)&lt;/a&gt;!)
        t = title[1].gsub!('&amp;#39;', "\'") || title[1]
        @episode.shownotes << Shownote.new(title: t, link: url[1])
      end


      @episode.save
    end
    index
    render :action => 'index'
  end

  def search
    searchCore params[:word]
  end

  def searchCore word
    @keyword = word
    @resultList = []

    @searchList = Shownote.all.select do |s|
      s.title[/#{@keyword}/i]
    end

    @searchList.each do |s|
      @resultList << {shownote: s, episode: Episode.find(s.episode_id)}
    end

    render :action => 'searchResult'
  end

  # GET /episodes/1
  # GET /episodes/1.json
  def show
  end

  # GET /episodes/new
  def new
    @episode = Episode.new
  end

  # GET /episodes/1/edit
  def edit
  end

  # POST /episodes
  # POST /episodes.json
  def create
    @episode = Episode.new(episode_params)

    respond_to do |format|
      if @episode.save
        format.html { redirect_to @episode, notice: 'Episode was successfully created.' }
        format.json { render :show, status: :created, location: @episode }
      else
        format.html { render :new }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /episodes/1
  # PATCH/PUT /episodes/1.json
  def update
    respond_to do |format|
      if @episode.update(episode_params)
        format.html { redirect_to @episode, notice: 'Episode was successfully updated.' }
        format.json { render :show, status: :ok, location: @episode }
      else
        format.html { render :edit }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /episodes/1
  # DELETE /episodes/1.json
  def destroy
    @episode.destroy
    respond_to do |format|
      format.html { redirect_to episodes_url, notice: 'Episode was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_episode
      @episode = Episode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def episode_params
      params.require(:episode).permit(:title, :link, :pubDate, :agenda, :description, :duration, :no, :mp3)
    end
end
