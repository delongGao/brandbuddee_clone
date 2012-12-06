class AdminController < ApplicationController

	def index
		if Rails.env.development?

		elsif Rails.env.production?
			redirect_to root_url
		end
	end

end
