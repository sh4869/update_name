# Coding: UTF-8

require 'twitter'

CONSUMER_KEY    = YOUR_CONSUMER_KEY
CONSUMER_SECRET = YOUR_CONSUMER_SECRET
ACCESS_TOKEN    = YOUR_ACCESS_TOKEN
ACCESS_SECRET   = YOUR_ACCESS_SECRET

@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_SECRET
end

@stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_SECRET
end

@orig_name, @screen_name = [:name, :screen_name].map{|x| @rest_client.user.send(x) }
@regexp_name = /^@#{@screen_name}\s+update_name(\s+(.+))?/
@regexp_url = /^@#{@screen_name}\s+update_url(\s+(.+))?/
@regexp_location = /^@#{@screen_name}\s+update_location(\s+(.+))?/
@count = 1
@time = Time.now
@day = @time.strftime("%x %H:%M")

def update_all(status)
  begin
    if status.text.match(@regexp_name)
      name = status.text.gsub(/^@#{@screen_name}\s+update_name\s?/,"")
      @rest_client.update_profile(name: name)
      text = "#{name}に改名しました。"
    elsif status.text.match(@regexp_url)
      url = status.text.gsub(/^@#{@screen_name}\s+update_url\s?/,"")
      @rest_client.update_profile(url: url) 
      text = "urlを#{url} に変更しました"
    elsif status.text.match(@regexp_location)
      location = status.text.gsub(/^@#{@screen_name}\s+update_location\s?/,"")
      @rest_client.update_profile(location: location)
      text = "私は #{location} にいます。"
    else
      return
    end
  
    puts "#{status.user.screen_name} #{text}"

    rescue => e
      p status, status.text
      p e
    ensure
      @rest_client.update("@#{status.user.screen_name} #{text}", :in_reply_to_status_id => status.id)
  end
end

@rest_client.update("update_all再開しました。(" + @day +")")

@stream_client.user do |object|
  next unless object.is_a? Twitter::Tweet and object.text.match(/(#{@regexp_name}|#{@regexp_url}|#{@regexp_location})/) 

  unless object.text.start_with? "RT"
    update_all(object)
  else
    puts "RTです"
  end
end

