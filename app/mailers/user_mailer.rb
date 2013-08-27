class UserMailer < ActionMailer::Base

	def redeem_confirmation(user_id, redeem, campaign, root_url)
		@user = User.find(user_id)
		@redeem_code = redeem.redeem_code
		@campaign = campaign
		@url = root_url
		mail(:to => @user.email, :subject => "You've just redeemed a brandbuddee reward!", :from => "brandbuddee <andy@brandbuddee.com>")
	end

	def secondary_gift_email(user, campaign, root_url)
		@user = user
		@campaign = campaign
		@url = root_url
		mail(:to => @user.email, :subject => "You've just earned a brandbuddee reward!", :from => "brandbuddee <andy@brandbuddee.com>")
	end

	def password_reset(password_reset, root_url)
		@name = password_reset.name
		@reset_code = password_reset.hash_code
		@url = root_url
		mail(:to => password_reset.email, :subject => "Reset your password", :from => "brandbuddee <andy@brandbuddee.com>")
	end

	def follow(user, follower, root_url)
		unless follower.first_name.nil? || follower.first_name.blank? || follower.last_name.nil? || follower.last_name.blank?
			@name = follower.first_name + ' ' + follower.last_name
		else
			@name = follower.nickname
		end
		@user = user
		@follower = follower
		@url = root_url
		mail(:to => user.email, :subject => "#{@name} is now following you on brandbuddee!", :from => "brandbuddee <andy@brandbuddee.com>")
	end

	def new_campaign_newsletter(email, root_url)
		@email = email
		@url = root_url
		mail(:to => email, :subject => "Top Stories of the Week", :from => "brandbuddee <andy@brandbuddee.com>")
	end

	def email_invite(email, subject, message)
		@message = message
		mail(:to => email, :subject => subject, :from => "brandbuddee <andy@brandbuddee.com>")
	end

	def email_white_label_invite(email, subject, message, brand, page_id)
		@message = message
		@brand = brand
		@page_id = page_id
		mail(:to => email, :subject => subject, :from => "#{@brand.name} <#{@brand.email}>")
	end

	def email_brice_error(message)
		@message = message
		mail(:to => "brice@brandbuddee.com", :subject => "brandbuddee ERROR - Please fix", :from => "brandbuddee <andy@brandbuddee.com>")
	end

end