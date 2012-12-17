class AdminController < ApplicationController

	def index

		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@share_month = Campaign.where(:date.gt => Time.now - 1.month)
				@share_two_months = Campaign.where(:date.gt => Time.now - 2.month)
				@share_month_count = @share_month.count
				@share_last_month_count = @share_two_months.count - @share_month_count

				@user_month = User.where(:date.gt => Time.now - 1.month)
				@user_two_months = User.where(:date.gt => Time.now - 2.month)
				@user_month_count = @user_month.count
				@user_last_month_count = @user_two_months.count - @user_month_count
				

				#@user_this_month = User.where(:date.gt => Time.now - 1.month, :date.lte => Time.now)

			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end

	end

end
