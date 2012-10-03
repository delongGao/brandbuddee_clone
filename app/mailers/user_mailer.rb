class UserMailer < ActionMailer::Base

	def subscriber_confirmation(user)
		@link = user.share_link
		mail(:to => user.email, :subject => "Thank you for signing up for the beta release of BrandBuddee!", :from => "BrandBuddee <noreply@brandbuddee.com>")
	end

end
