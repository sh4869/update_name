# Coding: UTF-8

require 'twitter'
require './keys.rb'


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
@regexp_name = /^@#{@screen_name}\s+update_name\s+(.+)$/
@regexp_name_2 = /(.+)?\(@#{@screen_name}\)(.+)?/
@regexp_url = /^@#{@screen_name}\s+update_url\s+(.+)$/
@regexp_location = /^@#{@screen_name}\s+update_location\s+(.+)$/
@count = 1
@time = Time.now
@day = @time.strftime("%x %H:%M")

def update_all(status)
  begin
    if status.text.match(@regexp_name) 
      name = $1
      if name && 20 < name.length
        text = "長すぎます(#{@count}回目)"
        raise "New name is too long"
        @count = @count + 1
      elsif 1 > name.length
        name = "4869"
        @rest_client.update_profile(name: name)
        text = "#{name}に戻しました。"
      else
        @rest_client.update_profile(name: name)
        text = "#{name}に改名しました。"
      end
    elsif status.text.match(@regexp_name_2)  
      name = status.text.gsub(/\(@#{@screen_name}\)/,"")      
      if name && 20 < name.length
        text = "長過ぎます(#{@count}回目)"
        raise "New name is too long"
  @count = @count + 1
      elsif 1 > name.length
  name = "4869"
  @rest_client.update_profile(name: name)
  text = "#{name}に戻しました。"
      else 
  @rest_client.update_profile(name: name)
  text = "#{name}に改名しました"
      end
    elsif status.text.match(@regexp_url)
      url = $1
      if url && 100  < url.length
        text = "長すぎます(#{@count}回目)"
        raise "New URL is too long"
        @count = @count  + 1
      elsif url.length  < 1
        url = "http://sh4869.net"
        @rest_client.update_profile(url: url) 
        text = "urlを#{url} に変更しました"
      else
        @rest_client.update_profile(url: url) 
        text = "urlを#{url} に変更しました"
      end
    elsif status.text.match(@regexp_location)
      location = $1
      if location && 30 < location.length
        text = "長すぎます(#{@count}回目)"
        raise "New location is too long"
        @count = @count + 1
      elsif location.length < 1
        location = "Tokyo"
        @rest_client.update_profile(location: location)
        text = "私は #{location} にいます。"
      else
        @rest_client.update_profile(location: location)
        text = "私は #{location} にいます。" 
      end
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
  next unless object.is_a? Twitter::Tweet and object.text.match(/(#{@regexp_name}|#{@regexp_name_2}|#{@regexp_url}|#{@regexp_location})/) 

  unless object.text.start_with? "RT"
    update_all(object)
  else
    puts "RTです"
  end
end

