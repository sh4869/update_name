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
@regexp = /^@#{@screen_name}\s+update_location\s+(.+)$/
@count = 1
@time = Time.now
@day = @time.strftime("%x %H:%M")

def update_location(status)
  begin
    if status.text.match(@regexp)
	place = $1
      else
	return
   end
  
    puts "#{status.user.screen_name} #{place}"
        
    if place && 30 < place.length
        text = "長すぎます(#{@count}回目)"
        raise "New place is too long"
      elsif 1 > place.length
        place = "Tokyo"
    end
   

   
    @rest_client.update_profile(location: place)
    text = place == "Tokyo" ? "元に戻しました" : "私は #{place} にいます!!"
      
    rescue => e
        p status, status.text
        p e
      ensure
        @rest_client.update("@#{status.user.screen_name} #{text}", :in_reply_to_status_id => status.id)
  end
  
  file = File.open("ul.txt", "a")
  file.write (place +" @#{status.user.screen_name} " + @day  + "\n\n")
  file.close

end

@rest_client.update("update_location再開しました。(" + @day +")")

@stream_client.user do |object|
  next unless object.is_a? Twitter::Tweet and object.text.match(@regexp) 

  unless object.text.start_with? "RT"
    update_location(object)
  else
    puts "RTです"
  end
end

