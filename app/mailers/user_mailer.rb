class UserMailer < ActionMailer::Base

	def subscriber_confirmation(user, root_url)
		@url = root_url
		@link = user.share_link
		mail(:to => user.email, :subject => "Thank you for signing up!", :from => "brandbuddee <noreply@brandbuddee.com>")
	end

	def redeem_confirmation(user_id, redeem, campaign, root_url)
		@user = User.find(user_id)
		@redeem_code = redeem.redeem_code
		@campaign = campaign
		@url = root_url
		mail(:to => @user.email, :subject => "You've just redeemed a brandbuddee reward!", :from => "brandbuddee <noreply@brandbuddee.com>")
	end

	def beta_invite(subscriber_email, invite_code, root_url)
		@invite_code = invite_code
		@url = root_url
		mail(:to => subscriber_email, :subject => "You've been invited to the brandbuddee beta!", :from => "brandbuddee <noreply@brandbuddee.com>")
	end

	def password_reset(password_reset, root_url)
		@name = password_reset.name
		@reset_code = password_reset.hash_code
		@url = root_url
		mail(:to => password_reset.email, :subject => "Reset your password", :from => "brandbuddee <noreply@brandbuddee.com>")
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
		mail(:to => user.email, :subject => "#{@name} is now following you on brandbuddee!", :from => "brandbuddee <noreply@brandbuddee.com>")
	end

	def campaign_newsletter(email, root_url)
		@email = email
		@url = root_url
		mail(:to => email, :subject => "Happy Easter!", :from => "brandbuddee <noreply@brandbuddee.com>")
	end

	def unsubscribe_confirm(email, hash, root_url)
		@email = email
		@hash = hash
		@url = root_url
		mail(:to => email, :subject => "Unsubscribe confirmation", :from => "brandbuddee <noreply@brandbuddee.com>")
	end

end