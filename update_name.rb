require 'twitter'
require 'tweetstream'

YOUR_CONSUMER_KEY = ""
YOUR_CONSUMER_SECRET = ""
YOUR_OAUTH_TOKEN = ""
YOUR_OAUTH_TOKEN_SECRET = ""
 
Twitter.configure do |config|
  config.consumer_key = YOUR_CONSUMER_KEY
  config.consumer_secret = YOUR_CONSUMER_SECRET
  config.oauth_token = YOUR_OAUTH_TOKEN
  config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
end


TweetStream.configure do |config|
  config.consumer_key = YOUR_CONSUMER_KEY
  config.consumer_secret = YOUR_CONSUMER_SECRET
  config.oauth_token = YOUR_OAUTH_TOKEN
  config.oauth_token_secret = YOUR_OAUTH_TOKEN_SECRET
  config.auth_method        = :oauth
end


 
TweetStream::Client.new.track("@sh4869sh update_name") do |status|
 if !status.text.index("RT")
    puts "#{status.user.name}: #{status.text}"
    name = status.text.slice(22..-1)
    user = "#{status.from_user}"
    puts name
   if status.text == "@sh4869sh update_name"
       Twitter.update_profile(:name => "4869")
       Twitter.update("@#{status.from_user} 元に戻しました")
    elsif name.split(//).size > 20
       Twitter.update("@#{status.from_user} 長すぎます")
    elsif   
       tweet = "@#{status.from_user} #{name} に改名しました!"
       Twitter.update_profile(:name => name)
       Twitter.update(tweet)
   end
  else
    puts "RTです"
 end
  day = Time.now
  file = File.open("un.txt", 'a') 
   file.write (name +" @" + user +" " + day.to_s + "\n")
  file.close
end
    


 
