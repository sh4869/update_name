# Coding: UTF-8
require 'twitter'
require 'oauth'
require 'oauth/consumer'
require './keys.rb'

SourcePath = File.expand_path('../', __FILE__)
TokenFile = "#{SourcePath}/token"

def oauth_first
  @consumer = OAuth::Consumer.new(CONSUMER_KEY ,CONSUMER_SECRET,{
	:site=>"https://api.twitter.com"
  })

  @request_token = @consumer.get_request_token

  puts "Please access this URL"
  puts ":#{@request_token.authorize_url}"
  puts "and get the Pin code."

  print "Enter your Pin code:"
  pin  = gets.chomp

  @access_token = @request_token.get_access_token(:oauth_verifier => pin)

  open(TokenFile, "a" ){|f| f.write("#{@access_token.token}\n")}
  open(TokenFile, "a" ){|f| f.write("#{@access_token.secret}\n")}
end

unless File::exist?(TokenFile)
  oauth_first
end

open(TokenFile){ |file|
  ACCESS_TOKEN = file.readlines.values_at(0)[0].gsub("\n","")
}
open(TokenFile){ |file|
  ACCESS_SECRET = file.readlines.values_at(1)[0].gsub("\n","")
}  

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
@regexp = /(#{@regexp_name}|#{@regexp_name_2}|#{@regexp_url}|#{@regexp_location})/
@time = Time.now
@day = @time.strftime("%x %H:%M")


def update_all(status)
  begin
	if status.text.match(@regexp_name)
	  name = $1  
	  hash = "name"
	elsif status.text.match(@regexp_name_2)  
	  name = status.text.gsub(/\(@#{@screen_name}\)/,"")     
	  hash = "name" 
	elsif status.text.match(@regexp_url)
	  url = $1
	  hash = "url"
	elsif status.text.match(@regexp_location)
	  location = $1
	  hash = "location"
	else
	  return
	end

	case hash
	when "name"
	  if 1 >  name.length || 20 < name.length  #名前が20文字以上の場合
		text = "Error:New name is too short or too long.(#{@day})"
		name = "4869"
	  else 
		text = "#{name}に改名しました。"
	  end
	  @rest_client.update_profile(name: name)
	when "url"
	  if 1 > url.length || 100  < url.length  #URLが100文字以上の場合  
		text = "Error:New URL is too short or too long.(#{@day})"
		url = "http://sh4869.net"
	  else
		text = "urlを#{url} に変更しました"
	  end
	  @rest_client.update_profile(url: url)
	when "location"
	  if 1 > location.length || 30 < location.length  #場所が30文字以上の場合
		text = "Error:New location is too short or too long.(#{@day})"	
		location = "Tokyo"
	  else
		text = "私は #{location} にいます。" 
	  end
	  @rest_client.update_profile(location: location)
	else 
	  puts "そんなhash存在しません。"
	end

	@rest_client.update("@#{status.user.screen_name} #{text}", :in_reply_to_status_id => status.id)

  rescue Twitter::Error::RequestTimeout 
	retry
  else 
	puts "update you!"
  ensure
	puts "#{status.user.screen_name} #{text}"
	#ファイルに書きこんで記録します
	file = File.open("un.txt", "a")
	file.write ("@#{status.user.screen_name}" + @day  + "\n\n")
	file.close  
  end
end

@rest_client.update("update_all再開しました。(" + @day +")")

@stream_client.user do |object|
  next unless object.is_a? Twitter::Tweet and object.text.match(@regexp) 

  unless object.text.start_with? "RT" #当てはまったツイートがRTから始まっていなかった場合
	update_all(object)
  else  #始まっていたら
	puts "RTです"
  end
end

