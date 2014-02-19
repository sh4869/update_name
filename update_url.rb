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
#@regexp = /(.+)?\(@sh4869sh\)(.+)?/
@regexp = /^@#{@screen_name}\s+update_url(\s+(.+))?/
@count = 1
@time = Time.now
@day = @time.strftime("%x %H:%M")

def update_url(status)
  begin
    if status.text.match(@regexp)
     #   name = status.text.gsub(/\(@sh4869sh\)/,"")
     # elsif status.text.match(@regexp2)
	url = status.text.gsub(/^@#{@screen_name}\s+update_url\s?/,"")
      else
	return
   end
  
    puts "#{status.user.screen_name} #{url}"
        
    if url && 40 < url.length
        text = "長すぎます(#{@count}回目)"
        raise "New name is too long"
      elsif 1 > url.length
        url = "4869"
    end
   

   
    @rest_client.update_profile(url: url)
    text = url == "http://sh4869.net" ? "元に戻しました" : "URLを #{url} に変更しました。"
      
    rescue => e
        p status, status.text
        p e
      ensure
        @rest_client.update("@#{status.user.screen_name} #{text}", :in_reply_to_status_id => status.id)
  end
  
  file = File.open("uu.txt", "a")
  file.write (url +" @#{status.user.screen_name} " + @day  + "\n\n")
  file.close

end

@rest_client.update("update_url再開しました。(" + @day +")")

@stream_client.user do |object|
  next unless object.is_a? Twitter::Tweet and object.text.match(@regexp) 

  unless object.text.start_with? "RT"
    update_url(object)
  else
    puts "RTです"
  end
end

