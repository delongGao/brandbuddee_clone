Bitly.configure do |config|
	config.api_version = 3
	if Rails.env.production?
		config.login = ENV['BITLY_USERNAME']
		config.api_key = ENV['BITLY_API_KEY']
	else
		config.login = "server4001"
		config.api_key = "R_01acf101e88825846e80cd4f7a93a861"
	end
end