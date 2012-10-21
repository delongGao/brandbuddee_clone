class UserMailer < ActionMailer::Base

	def subscriber_confirmation(user, root_url)
		@url = root_url
		@link = user.share_link
		mail(:to => user.email, :subject => "Thank you for signing up!", :from => "BrandBuddee <noreply@brandbuddee.com>")
	end

	def redeem_confirmation(user_id, redeem, campaign, root_url)
		@user = User.find(user_id)
		@redeem_code = redeem.redeem_code
		@campaign = campaign
		@url = root_url
		mail(:to => @user.email, :subject => "You've just redeemed a brandbuddee reward!", :from => "BrandBuddee <noreply@brandbuddee.com>")
	end

	def beta_invite(subscriber_email, invite_code, root_url)
		@invite_code = invite_code
		@url = root_url
		mail(:to => subscriber_email, :subject => "You've been invited to the brandbuddee beta!", :from => "BrandBuddee <noreply@brandbuddee.com>")
	end

end