json.array!(@episodes) do |episode|
  json.extract! episode, :id, :title, :link, :pubDate, :agenda, :description, :duration, :no, :mp3
  json.url episode_url(episode, format: :json)
end
