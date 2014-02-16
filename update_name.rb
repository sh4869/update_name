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
  config.oauth_token        = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_SECRET
end

@orig_name, @screen_name = [:name, :screen_name].map{|x| @rest_client.user.send(x) }
@regexp = /(.+)?\(@sh4869sh\)(.+)?/
@regexp2 = /^@#{@screen_name}\s+update_name(\s+(.+))?/
@count = 1
@time = Time.now
@day = @time.strftime("%x %H:%M")

def update_name(status)
  begin
    if status.text.match(@regexp)
        name = status.text.gsub(/\(@sh4869sh\)/,"")
      elsif status.text.match(@regexp2)
	name = status.text.gsub(/^@sh4869sh\s+update_name\s?/,"")
      else
	return
   end
  
    puts "#{status.user.screen_name} #{name}"
        
    if name && 20 < name.length
        text = "長すぎます(#{count}回目)"
        raise "New name is too long"
      elsif 1 > name.length
        name = "4869"
    end
   

   
    @rest_client.update_profile(name: name)
    text = name == "4869" ? "元に戻しました" : "#{name} に改名しました!"
      
    rescue => e
        p status, status.text
        p e
      ensure
        @rest_client.update("@#{status.user.screen_name} #{text}", :in_reply_to_status_id => status.id)
  end
  
  file = File.open("un.txt", "a")
  file.write (name +" @#{status.user.screen_name} " + @day  + "\n\n")
  file.close

end

@rest_client.update("update_name再開しました。(" + @day +")")

@stream_client.user do |object|
  next unless object.is_a? Twitter::Tweet and object.text.match(/(#{@regexp}|#{@regexp2})/) 

  unless object.text.start_with? "RT"
    update_name(object)
  else
    puts "RTです"
  end
end

