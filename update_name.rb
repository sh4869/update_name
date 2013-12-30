require 'twitter'
require 'tweetstream'
 
Twitter.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.oauth_token = ''
  config.oauth_token_secret = ''
end


TweetStream.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.oauth_token = ''
  config.oauth_token_secret = ''
  config.auth_method        = :oauth
end


 
TweetStream::Client.new.track("@sh4869sh update_name") do |status|
 if !status.text.index("RT")
    puts "#{status.user.name}: #{status.text}"
    name = status.text.slice(22..-1)
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
end
