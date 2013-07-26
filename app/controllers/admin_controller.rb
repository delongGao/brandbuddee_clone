class AdminController < ApplicationController

	def index

		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || current_user.account_type == 'mini admin' || Rails.env.development?
				@share_month = Share.where(:date.gt => Time.now - 1.month)
				@share_two_months = Share.where(:date.gt => Time.now - 2.month)
				@share_month_count = @share_month.count
				@share_last_month_count = @share_two_months.count - @share_month_count

				@user_month = User.where(:date.gt => Time.now - 1.month)
				@user_two_months = User.where(:date.gt => Time.now - 2.month)
				@user_month_count = @user_month.count
				@user_last_month_count = @user_two_months.count - @user_month_count

				@trackings_month = Tracking.where(:date.gt => Time.now - 1.month)
				@trackings_two_months = Tracking.where(:date.gt => Time.now - 2.month)
				#@user_this_month = User.where(:date.gt => Time.now - 1.month, :date.lte => Time.now)

				#@share_views_month = 0
				# @share_month.each do |s|
				# 	@share_views_month = @share_views_month + s.unique_page_views + s.trackings.size
				# end
				#@share_views_last_month = 0
				# views_last_month = @share_month - @share_two_months
				# views_last_month.each do |s|
				# 	@share_views_last_month = @share_views_last_month + s.unique_page_views + s.trackings.size
				# end
				#@views_month_count = 
				@views_last_month_count = @user_two_months.count - @user_month_count


				@users_weekly = User.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@redeems_weekly = Redeem.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@campaigns_weekly = Campaign.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@brands_weekly = Brand.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])

				@last_users = User.all.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 4

				@user_all = User.all.order_by([:date, :desc])
				@campaign_all = Campaign.all.order_by([:date, :desc])
				@category_all = Category.all.order_by([:date, :desc])
				@location_all = Location.all.order_by([:date, :desc])
				@brand_all = Brand.all.order_by([:date, :desc])
				@share_all = Share.all.order_by([:date, :desc])
				@tracking_all = Tracking.all.order_by([:date, :desc])
				@redeem_all = Redeem.all.order_by([:date, :desc])

				

			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end

	end

	def users
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@users = User.all.order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def campaigns
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@campaigns = Campaign.all.order_by([:date, :desc])
				@location_all = Location.all.order_by([:name, :asc])
				@category_all = Category.all.order_by([:name, :asc])
				@brand_all = Brand.all.order_by([:name, :asc])
				@link = Campaign.assign_link()
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def campaign_delete
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@campaign = Campaign.find(params[:_id])
				@campaign.destroy
				flash[:notice] = "#{@campaign.title} campaign Destroyed"
				redirect_to(:action => 'campaigns')
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def campaign_new
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				if params[:brands].nil? || params[:brands].empty?
					flash[:error] = "ERROR: You forgot to select a brand!!!"
					redirect_to "/admin/campaigns"
			    elsif params[:categories].nil? || params[:categories].empty?
			    	flash[:error] = "ERROR: You forgot to select a category!!!"
			    	redirect_to "/admin/campaigns"
			    else
					@brand = Brand.find(params[:brands])
			    	@campaign = @brand.campaigns.create!(params[:campaign])

				    unless params[:date_year].blank? || params[:date_month].blank? || params[:date_day].blank? || params[:date_hour].blank? || params[:date_minute].blank?
				      date_time = DateTime.new(params[:date_year].to_i, params[:date_month].to_i, params[:date_day].to_i, params[:date_hour].to_i, params[:date_minute].to_i, 0, "-0700")
				      @campaign.end_date = date_time
				    end

				    if params[:campaign][:tweet].blank?
				      @campaign.tweet = "Check out #{@campaign.title} via @brandbuddee"
				    end
				    category = Category.find(params[:categories])
				    @campaign.category_ids << params[:categories]
				    @campaign.location = params[:location]

				    if !params[:task_blog_post].nil? && params[:task_blog_post]["0"] == "true"
				    	if !params[:task_blog_post]["1"].empty? && !params[:task_blog_post]["2"].empty? && !params[:task_blog_post]["3"].empty?
				    		@campaign.task_blog_post[:use_it] = true
				    		@campaign.task_blog_post[:title] = params[:task_blog_post]["1"]
				    		@campaign.task_blog_post[:description] = params[:task_blog_post]["2"]
				    		@campaign.task_blog_post[:points] = params[:task_blog_post]["3"].to_i
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
				    	end
				    end # Blog Post Task
				    if !params[:task_facebook].nil? && params[:task_facebook]["0"] == "true"
				    	if !params[:task_facebook]["1"].empty? && !params[:task_facebook]["2"].empty? && !params[:task_facebook]["3"].empty? && !params[:task_facebook]["4"].empty?
				    		@campaign.task_facebook[:use_it] = true
				    		@campaign.task_facebook[:title] = params[:task_facebook]["1"]
				    		@campaign.task_facebook[:description] = params[:task_facebook]["2"]
				    		@campaign.task_facebook[:points] = params[:task_facebook]["3"].to_i
				    		@campaign.task_facebook[:link] = params[:task_facebook]["4"]
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Like On Facebook. Make sure you fill out ALL fields."
				    	end
				    end # Facebook Like Task
				    if !params[:task_twitter].nil? && params[:task_twitter]["0"] == "true"
				    	if !params[:task_twitter]["1"].empty? && !params[:task_twitter]["2"].empty? && !params[:task_twitter]["3"].empty? && !params[:task_twitter]["4"].empty?
				    		@campaign.task_twitter[:use_it] = true
				    		@campaign.task_twitter[:title] = params[:task_twitter]["1"]
				    		@campaign.task_twitter[:description] = params[:task_twitter]["2"]
				    		@campaign.task_twitter[:points] = params[:task_twitter]["3"].to_i
				    		@campaign.task_twitter[:link] = params[:task_twitter]["4"]
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Follow On Twitter. Make sure you fill out ALL fields."
				    	end
				    end # Twitter Follow Task
				    if !params[:task_custom_1].nil? && params[:task_custom_1]["0"] == "true"
				    	if !params[:task_custom_1]["1"].empty? && !params[:task_custom_1]["2"].empty? && !params[:task_custom_1]["3"].empty? && !params[:task_custom_1]["4"].empty?
				    		@campaign.task_custom_1[:use_it] = true
				    		@campaign.task_custom_1[:title] = params[:task_custom_1]["1"]
				    		@campaign.task_custom_1[:description] = params[:task_custom_1]["2"]
				    		@campaign.task_custom_1[:points] = params[:task_custom_1]["3"]
				    		@campaign.task_custom_1[:link] = params[:task_custom_1]["4"]
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Custom #1. Make sure you fill out ALL fields."
				    	end
				    end # Custom Task #1
				    if !params[:task_custom_2].nil? && params[:task_custom_2]["0"] == "true"
				    	if !params[:task_custom_2]["1"].empty? && !params[:task_custom_2]["2"].empty? && !params[:task_custom_2]["3"].empty? && !params[:task_custom_2]["4"].empty?
				    		@campaign.task_custom_2[:use_it] = true
				    		@campaign.task_custom_2[:title] = params[:task_custom_2]["1"]
				    		@campaign.task_custom_2[:description] = params[:task_custom_2]["2"]
				    		@campaign.task_custom_2[:points] = params[:task_custom_2]["3"]
				    		@campaign.task_custom_2[:link] = params[:task_custom_2]["4"]
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Custom #2. Make sure you fill out ALL fields."
				    	end
				    end # Custom Task #2
				    if !params[:task_custom_3].nil? && params[:task_custom_3]["0"] == "true"
				    	if !params[:task_custom_3]["1"].empty? && !params[:task_custom_3]["2"].empty? && !params[:task_custom_3]["3"].empty? && !params[:task_custom_3]["4"].empty?
				    		@campaign.task_custom_3[:use_it] = true
				    		@campaign.task_custom_3[:title] = params[:task_custom_3]["1"]
				    		@campaign.task_custom_3[:description] = params[:task_custom_3]["2"]
				    		@campaign.task_custom_3[:points] = params[:task_custom_3]["3"]
				    		@campaign.task_custom_3[:link] = params[:task_custom_3]["4"]
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Custom #3. Make sure you fill out ALL fields."
				    	end
				    end # Custom Task #3
				    if !params[:task_custom_4].nil? && params[:task_custom_4]["0"] == "true"
				    	if !params[:task_custom_4]["1"].empty? && !params[:task_custom_4]["2"].empty? && !params[:task_custom_4]["3"].empty? && !params[:task_custom_4]["4"].empty?
				    		@campaign.task_custom_4[:use_it] = true
				    		@campaign.task_custom_4[:title] = params[:task_custom_4]["1"]
				    		@campaign.task_custom_4[:description] = params[:task_custom_4]["2"]
				    		@campaign.task_custom_4[:points] = params[:task_custom_4]["3"]
				    		@campaign.task_custom_4[:link] = params[:task_custom_4]["4"]
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Custom #4. Make sure you fill out ALL fields."
				    	end
				    end # Custom Task #4
				    if !params[:task_custom_5].nil? && params[:task_custom_5]["0"] == "true"
				    	if !params[:task_custom_5]["1"].empty? && !params[:task_custom_5]["2"].empty? && !params[:task_custom_5]["3"].empty? && !params[:task_custom_5]["4"].empty?
				    		@campaign.task_custom_5[:use_it] = true
				    		@campaign.task_custom_5[:title] = params[:task_custom_5]["1"]
				    		@campaign.task_custom_5[:description] = params[:task_custom_5]["2"]
				    		@campaign.task_custom_5[:points] = params[:task_custom_5]["3"]
				    		@campaign.task_custom_5[:link] = params[:task_custom_5]["4"]
				    	else
				    		flash[:error] = "WARNING: Unable to add Task: Custom #5. Make sure you fill out ALL fields."
				    	end
				    end # Custom Task #5
				    if !params[:engagement_tasks].nil? && !params[:engagement_tasks]["Left"].blank?
				    	case params[:engagement_tasks]["Left"]
				    	when "Facebook"
				    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["Left"] unless @campaign.task_facebook[:use_it].nil? || @campaign.task_facebook[:use_it] != true
				    	when "Twitter"
				    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["Left"] unless @campaign.task_twitter[:use_it].nil? || @campaign.task_twitter[:use_it] != true
				    	when "Custom1"
				    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["Left"] unless @campaign.task_custom_1[:use_it].nil? || @campaign.task_custom_1[:use_it] != true
				    	when "Custom2"
				    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["Left"] unless @campaign.task_custom_2[:use_it].nil? || @campaign.task_custom_2[:use_it] != true
				    	when "Custom3"
				    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["Left"] unless @campaign.task_custom_3[:use_it].nil? || @campaign.task_custom_3[:use_it] != true
				    	when "Custom4"
				    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["Left"] unless @campaign.task_custom_4[:use_it].nil? || @campaign.task_custom_4[:use_it] != true
				    	when "Custom5"
				    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["Left"] unless @campaign.task_custom_5[:use_it].nil? || @campaign.task_custom_5[:use_it] != true
				    	else
				    		flash[:error] = "WARNING: Unable to assign Tasks to Engagement Bar."
				    	end
				    end # Engagement Bar Left Task
				    if !params[:engagement_tasks].nil? && !params[:engagement_tasks]["Right"].blank?
				    	case params[:engagement_tasks]["Right"]
				    	when "Facebook"
				    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["Right"] unless @campaign.task_facebook[:use_it].nil? || @campaign.task_facebook[:use_it] != true
				    	when "Twitter"
				    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["Right"] unless @campaign.task_twitter[:use_it].nil? || @campaign.task_twitter[:use_it] != true
				    	when "Custom1"
				    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["Right"] unless @campaign.task_custom_1[:use_it].nil? || @campaign.task_custom_1[:use_it] != true
				    	when "Custom2"
				    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["Right"] unless @campaign.task_custom_2[:use_it].nil? || @campaign.task_custom_2[:use_it] != true
				    	when "Custom3"
				    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["Right"] unless @campaign.task_custom_3[:use_it].nil? || @campaign.task_custom_3[:use_it] != true
				    	when "Custom4"
				    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["Right"] unless @campaign.task_custom_4[:use_it].nil? || @campaign.task_custom_4[:use_it] != true
				    	when "Custom5"
				    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["Right"] unless @campaign.task_custom_5[:use_it].nil? || @campaign.task_custom_5[:use_it] != true
				    	else
				    		flash[:error] = "WARNING: Unable to assign Tasks to Engagement Bar."
				    	end
				    end # Engagement Bar Right Task

				    if !params[:campaign][:share_link].nil? && /^(https?|ftp):\/\//.match(params[:campaign][:share_link])
					    if @campaign.save
					      flash[:notice] = "Campaign successfully created"
					      redirect_to(:action => 'campaigns')
					    else
					      flash[:notice] = "Uh oh"
					    end
					else
						@campaign.destroy
						flash[:error] = "ERROR: Campaign Share Link must start with http:// https:// or ftp://"
						redirect_to "/admin/campaigns"
					end
				end
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def locations
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@locations = Location.all.order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def location_new
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@location = Location.create!(params[:location])

			    if @location.save
			      flash[:notice] = "Location successfully created"
			      redirect_to(:action => 'locations')
			    else
			      flash[:notice] = "Uh oh"
			    end
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def location_delete
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@location = Location.find(params[:_id])
				@location.destroy
				flash[:notice] = "#{@location.city} Location Destroyed"
				redirect_to(:action => 'locations')
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def redeems
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@redeems = Redeem.all.order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def categories
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@categories = Category.all.order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def category_new
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@category = Category.create!(params[:category])

			    if @category.save
			      flash[:notice] = "Category successfully created"
			      redirect_to(:action => 'categories')
			    else
			      flash[:notice] = "Uh oh"
			    end
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def category_delete
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@category = Category.find(params[:_id])
			    @category.destroy
			    flash[:notice] = "#{@category.name} Category Destroyed"
			    redirect_to(:action => 'categories')
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def brands
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || current_user.account_type == 'mini admin' || Rails.env.development?
				@brands = Brand.all.order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def brand_new_index
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@brand = Brand.new
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def brand_new
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				begin
					@brand = Brand.new(params[:brand])
					unless @brand.bio.blank?
						unless @brand.website.blank? || !@brand.website.match(/\b((http(s?):\/\/)([a-z0-9\-]+\.)+(MUSEUM|TRAVEL|AERO|ARPA|ASIA|EDU|GOV|MIL|MOBI|COOP|INFO|NAME|BIZ|CAT|COM|INT|JOBS|NET|ORG|PRO|TEL|A[CDEFGILMNOQRSTUWXZ]|B[ABDEFGHIJLMNORSTVWYZ]|C[ACDFGHIKLMNORUVXYZ]|D[EJKMOZ]|E[CEGHRSTU]|F[IJKMOR]|G[ABDEFGHILMNPQRSTUWY]|H[KMNRTU]|I[DELMNOQRST]|J[EMOP]|K[EGHIMNPRWYZ]|L[ABCIKRSTUVY]|M[ACDEFGHKLMNOPQRSTUVWXYZ]|N[ACEFGILOPRUZ]|OM|P[AEFGHKLMNRSTWY]|QA|R[EOSUW]|S[ABCDEGHIJKLMNORTUVYZ]|T[CDFGHJKLMNOPRTVWZ]|U[AGKMSYZ]|V[ACEGINU]|W[FS]|Y[ETU]|Z[AMW])(:[0-9]{1,5})?((\/([a-z0-9_\-\.~]*)*)?((\/)?\?[a-z0-9+_\-\.%=&amp;]*)?)?(#[a-zA-Z0-9!$&'()*+.=-_~:@\/?]*)?)/i)
							unless @brand.manager_first.blank? || @brand.manager_first.size > 75
								unless @brand.manager_last.blank? || @brand.manager_last.size > 75
									unless @brand.nickname.blank? || !@brand.nickname.match(/^[a-z0-9_-]+$/) || @brand.nickname.size > 45
										@brand.email = @brand.email.downcase
										@brand.provider = "email"
										@brand.last_login = DateTime.now
										@brand.date = DateTime.now
										if @brand.save
											flash[:success] = "Brand successfully created"
											redirect_to(:action => 'brands')
										else
											render "brand_new_index"
										end
									else
										@brand.errors.add(:nickname, "cannot be blank, must contain only lowercase letters, numbers, dashes, and underscores, and cannot be longer than 45 characters.")
										render "brand_new_index"
									end
								else
									@brand.errors.add(:manager_last, "cannot be blank or longer than 75 characters.")
									render "brand_new_index"
								end
							else
								@brand.errors.add(:manager_first, "cannot be blank or longer than 75 characters.")
								render "brand_new_index"
							end
						else
							@brand.errors.add(:website, "cannot be blank and must be valid, starting with http:// or https://.")
							render "brand_new_index"
						end
					else
						@brand.errors.add(:bio, "cannot be blank.")
						render "brand_new_index"
					end
				rescue OpenURI::HTTPError
					flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
					redirect_to(:action => 'brands')
				rescue CarrierWave::IntegrityError
					flash[:error] = "The URL you are trying to upload an image from does not appear to point to an image file. You may only use the following file types: .jpg, .jpeg, .gif, & .png"
					redirect_to(:action => 'brands')
				rescue CarrierWave::DownloadError
					flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
					redirect_to(:action => 'brands')
				rescue CarrierWave::InvalidParameter
					flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
					redirect_to(:action => 'brands')
				rescue CarrierWave::ProcessingError
					flash[:error] = "An error occured while processing the image you wish to upload from the web. Are you sure the URL points to a valid image file? If so, please try again. Alternatively you can download and then upload the image yourself."
					redirect_to(:action => 'brands')
				rescue CarrierWave::UploadError
					flash[:error] = "The URL you are trying to upload an image from caused an error. Are you sure it points to a valid image file? If so, please try again. Alternatively you can download and then upload the image yourself."
					redirect_to(:action => 'brands')
				end
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def brand_edit
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@brand = Brand.find(params[:_id])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def brand_update
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@brand = Brand.find(params[:brand][:id])
				begin
					if !params[:brand][:remove_brand_logo].nil? && params[:brand][:remove_brand_logo] == "1"
						@brand.remove_brand_logo!
						@brand.brand_logo = nil
						@brand.save!(validate: false)
					end
					@brand.attributes = params[:brand]
					@brand.last_updated = DateTime.now
					if @brand.save
						flash[:success] = "Successfully updated."
						redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
					else
						render "brand_edit"
					end
				rescue OpenURI::HTTPError
					flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
					redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				rescue CarrierWave::IntegrityError
					flash[:error] = "The URL you are trying to upload an image from does not appear to point to an image file. You may only use the following file types: .jpg, .jpeg, .gif, & .png"
					redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				rescue CarrierWave::DownloadError
					flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
					redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				rescue CarrierWave::InvalidParameter
					flash[:error] = "The URL you are trying to upload an image from does not appear to be valid. Please enter a new one and try again. Or, you can download and then upload the image yourself."
					redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				rescue CarrierWave::ProcessingError
					flash[:error] = "An error occured while processing the image you wish to upload from the web. Are you sure the URL points to a valid image file? If so, please try again. Alternatively you can download and then upload the image yourself."
					redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				rescue CarrierWave::UploadError
					flash[:error] = "The URL you are trying to upload an image from caused an error. Are you sure it points to a valid image file? If so, please try again. Alternatively you can download and then upload the image yourself."
					redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				end

				# if @brand.update_attributes(params[:brand])
				#   flash[:notice] = "Successfully updated."
				#   redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				# else
				#   flash[:notice] = "Uh oh... something went wrong. Please try again."
				#   redirect_to "#{root_url}admin/brands/edit?_id=#{params[:brand][:id]}"
				# end
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def brand_delete
		if current_user
			if current_user.account_type == 'super admin' || Rails.env.development?
				@brand = Brand.find(params[:_id])
			    @brand.destroy
			    flash[:notice] = "#{@brand.name} brand Destroyed"
			    redirect_to(:action => 'brands')
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def view_campaign
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || current_user.account_type == 'mini admin' || Rails.env.development?
				@campaign = Campaign.find(params[:_id])

				@share_month = Share.where(:date.gt => Time.now - 1.month, :campaign_id => params[:_id])
				@share_two_months = Share.where(:date.gt => Time.now - 2.month, :campaign_id => params[:_id])
				@share_month_count = @share_month.count
				@share_last_month_count = @share_two_months.count - @share_month_count



				#@users_weekly = User.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				#@users_weekly = @campaign.users.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@users_weekly = Share.where(:date.gt => Time.now - 1.week, :campaign_id => params[:_id])

				share_ids = Share.where(:campaign_id => params[:_id]).map(&:_id)
				@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week, :share_id.in => share_ids)
				#@trackings_weekly = Tracking.where(:date.gt => Time.now - 1.week).order_by([:date, :desc])
				@redeems_weekly = Redeem.where(:date.gt => Time.now - 1.week, :campaign_id => params[:_id]).order_by([:date, :desc])

				@users_monthly = Share.where(:date.gt => Time.now - 1.month, :campaign_id => params[:_id])
				@trackings_monthly = Tracking.where(:date.gt => Time.now - 1.month, :share_id.in => share_ids)
				@redeems_monthly = Redeem.where(:date.gt => Time.now - 1.month, :campaign_id => params[:_id]).order_by([:date, :desc])

				#@last_users = User.all.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 4
				@last_users = @campaign.users.order_by([:date, :desc]).paginate :page => params[:page], :per_page => 4

				@user_all = Share.where(:campaign_id => params[:_id])
				@share_all = Share.all.order_by([:date, :desc])
				@tracking_all = Tracking.where(:share_id.in => share_ids)
				@redeem_all = @campaign.redeems

				@total_pinterest_clicks = @campaign.pinterest_clicks
				@total_twitter_clicks = @campaign.twitter_clicks
				@total_facebook_clicks = @campaign.facebook_clicks
				@total_tumblr_clicks = @campaign.tumblr_clicks
				@total_social_clicks = @total_pinterest_clicks + @total_twitter_clicks + @total_facebook_clicks + @total_tumblr_clicks
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def edit_campaign
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@category_all = Category.all.order_by([:name, :asc])
		    	@brand_all = Brand.all.order_by([:name, :asc])
		    	@location_all = Location.all.order_by([:city, :desc])

				@campaign = Campaign.find(params[:_id])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def update_campaign
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@campaign = Campaign.find(params[:campaign][:id])
				
				unless params[:brand].blank?
					@campaign.brand_id = params[:brand]
				end

				unless params[:category].blank?
					# @campaign.category_ids << params[:brand]
					# @campaign.save

					@campaign.categories.clear
					category = Category.find(params[:category])
					@campaign.categories << category
				end

				unless params[:date_year].blank? || params[:date_month].blank? || params[:date_day].blank? || params[:date_hour].blank? || params[:date_minute].blank?
					date_time = DateTime.new(params[:date_year].to_i, params[:date_month].to_i, params[:date_day].to_i, params[:date_hour].to_i, params[:date_minute].to_i, 0, "-0700")
					@campaign.end_date = date_time
				end
				
				unless params[:campaign][:location].blank?
					@location = Location.find(params[:campaign][:location])
					@campaign.location_id = @location.id
				end

				if !params[:task_blog_post].nil? && params[:task_blog_post]["0"] == "UPDATE"
			    	if !params[:task_blog_post]["1"].empty? && !params[:task_blog_post]["2"].empty? && !params[:task_blog_post]["3"].empty?
			    		@campaign.task_blog_post[:use_it] = true
			    		@campaign.task_blog_post[:title] = params[:task_blog_post]["1"]
			    		@campaign.task_blog_post[:description] = params[:task_blog_post]["2"]
			    		@campaign.task_blog_post[:points] = params[:task_blog_post]["3"].to_i
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_blog_post = {}
			    end # Blog Post Task

			    if !params[:task_facebook].nil? && params[:task_facebook]["0"] == "UPDATE"
			    	if !params[:task_facebook]["1"].empty? && !params[:task_facebook]["2"].empty? && !params[:task_facebook]["3"].empty?
			    		@campaign.task_facebook[:use_it] = true
			    		@campaign.task_facebook[:title] = params[:task_facebook]["1"]
			    		@campaign.task_facebook[:description] = params[:task_facebook]["2"]
			    		@campaign.task_facebook[:points] = params[:task_facebook]["3"].to_i
			    		@campaign.task_facebook[:link] = params[:task_facebook]["4"]
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_facebook = {}
			    end # Facebook Task

			    if !params[:task_twitter].nil? && params[:task_twitter]["0"] == "UPDATE"
			    	if !params[:task_twitter]["1"].empty? && !params[:task_twitter]["2"].empty? && !params[:task_twitter]["3"].empty?
			    		@campaign.task_twitter[:use_it] = true
			    		@campaign.task_twitter[:title] = params[:task_twitter]["1"]
			    		@campaign.task_twitter[:description] = params[:task_twitter]["2"]
			    		@campaign.task_twitter[:points] = params[:task_twitter]["3"].to_i
			    		@campaign.task_twitter[:link] = params[:task_twitter]["4"]
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_twitter = {}
			    end # Twitter Task

			    if !params[:task_custom_1].nil? && params[:task_custom_1]["0"] == "UPDATE"
			    	if !params[:task_custom_1]["1"].empty? && !params[:task_custom_1]["2"].empty? && !params[:task_custom_1]["3"].empty?
			    		@campaign.task_custom_1[:use_it] = true
			    		@campaign.task_custom_1[:title] = params[:task_custom_1]["1"]
			    		@campaign.task_custom_1[:description] = params[:task_custom_1]["2"]
			    		@campaign.task_custom_1[:points] = params[:task_custom_1]["3"].to_i
			    		@campaign.task_custom_1[:link] = params[:task_custom_1]["4"]
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_custom_1 = {}
			    end # Custom 1 Task

			    if !params[:task_custom_2].nil? && params[:task_custom_2]["0"] == "UPDATE"
			    	if !params[:task_custom_2]["1"].empty? && !params[:task_custom_2]["2"].empty? && !params[:task_custom_2]["3"].empty?
			    		@campaign.task_custom_2[:use_it] = true
			    		@campaign.task_custom_2[:title] = params[:task_custom_2]["1"]
			    		@campaign.task_custom_2[:description] = params[:task_custom_2]["2"]
			    		@campaign.task_custom_2[:points] = params[:task_custom_2]["3"].to_i
			    		@campaign.task_custom_2[:link] = params[:task_custom_2]["4"]
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_custom_2 = {}
			    end # Custom 2 Task

			    if !params[:task_custom_3].nil? && params[:task_custom_3]["0"] == "UPDATE"
			    	if !params[:task_custom_3]["1"].empty? && !params[:task_custom_3]["2"].empty? && !params[:task_custom_3]["3"].empty?
			    		@campaign.task_custom_3[:use_it] = true
			    		@campaign.task_custom_3[:title] = params[:task_custom_3]["1"]
			    		@campaign.task_custom_3[:description] = params[:task_custom_3]["2"]
			    		@campaign.task_custom_3[:points] = params[:task_custom_3]["3"].to_i
			    		@campaign.task_custom_3[:link] = params[:task_custom_3]["4"]
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_custom_3 = {}
			    end # Custom 3 Task

			    if !params[:task_custom_4].nil? && params[:task_custom_4]["0"] == "UPDATE"
			    	if !params[:task_custom_4]["1"].empty? && !params[:task_custom_4]["2"].empty? && !params[:task_custom_4]["3"].empty?
			    		@campaign.task_custom_4[:use_it] = true
			    		@campaign.task_custom_4[:title] = params[:task_custom_4]["1"]
			    		@campaign.task_custom_4[:description] = params[:task_custom_4]["2"]
			    		@campaign.task_custom_4[:points] = params[:task_custom_4]["3"].to_i
			    		@campaign.task_custom_4[:link] = params[:task_custom_4]["4"]
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_custom_4 = {}
			    end # Custom 4 Task

			    if !params[:task_custom_5].nil? && params[:task_custom_5]["0"] == "UPDATE"
			    	if !params[:task_custom_5]["1"].empty? && !params[:task_custom_5]["2"].empty? && !params[:task_custom_5]["3"].empty?
			    		@campaign.task_custom_5[:use_it] = true
			    		@campaign.task_custom_5[:title] = params[:task_custom_5]["1"]
			    		@campaign.task_custom_5[:description] = params[:task_custom_5]["2"]
			    		@campaign.task_custom_5[:points] = params[:task_custom_5]["3"].to_i
			    		@campaign.task_custom_5[:link] = params[:task_custom_5]["4"]
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Blog Post. Make sure you fill out ALL fields."
			    	end
			    else
			    	@campaign.task_custom_5 = {}
			    end # Custom 5 Task

			    if !params[:engagement_tasks].nil? && !params[:engagement_tasks]["left"].blank?
			    	case params[:engagement_tasks]["left"]
			    	when "Facebook"
			    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["left"] unless @campaign.task_facebook[:use_it].nil? || @campaign.task_facebook[:use_it] != true
			    	when "Twitter"
			    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["left"] unless @campaign.task_twitter[:use_it].nil? || @campaign.task_twitter[:use_it] != true
			    	when "Custom1"
			    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["left"] unless @campaign.task_custom_1[:use_it].nil? || @campaign.task_custom_1[:use_it] != true
			    	when "Custom2"
			    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["left"] unless @campaign.task_custom_2[:use_it].nil? || @campaign.task_custom_2[:use_it] != true
			    	when "Custom3"
			    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["left"] unless @campaign.task_custom_3[:use_it].nil? || @campaign.task_custom_3[:use_it] != true
			    	when "Custom4"
			    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["left"] unless @campaign.task_custom_4[:use_it].nil? || @campaign.task_custom_4[:use_it] != true
			    	when "Custom5"
			    		@campaign.engagement_tasks[:left] = params[:engagement_tasks]["left"] unless @campaign.task_custom_5[:use_it].nil? || @campaign.task_custom_5[:use_it] != true
			    	else
			    		if @campaign.engagement_tasks[:right].nil? || @campaign.engagement_tasks[:right].empty?
			    			@campaign.engagement_tasks = {}
			    		else
			    			engageright = @campaign.engagement_tasks[:right]
			    			@campaign.engagement_tasks = {}
			    			@campaign.engagement_tasks[:right] = engageright
			    		end
			    	end
			    else
			    	if @campaign.engagement_tasks[:right].nil? || @campaign.engagement_tasks[:right].empty?
			    		@campaign.engagement_tasks = {}
			    	else
			    		engageright = @campaign.engagement_tasks[:right]
		    			@campaign.engagement_tasks = {}
		    			@campaign.engagement_tasks[:right] = engageright
			    	end
			    end # Engagement Bar Left Task
			    if !params[:engagement_tasks].nil? && !params[:engagement_tasks]["right"].blank?
			    	case params[:engagement_tasks]["right"]
			    	when "Facebook"
			    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["right"] unless @campaign.task_facebook[:use_it].nil? || @campaign.task_facebook[:use_it] != true
			    	when "Twitter"
			    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["right"] unless @campaign.task_twitter[:use_it].nil? || @campaign.task_twitter[:use_it] != true
			    	when "Custom1"
			    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["right"] unless @campaign.task_custom_1[:use_it].nil? || @campaign.task_custom_1[:use_it] != true
			    	when "Custom2"
			    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["right"] unless @campaign.task_custom_2[:use_it].nil? || @campaign.task_custom_2[:use_it] != true
			    	when "Custom3"
			    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["right"] unless @campaign.task_custom_3[:use_it].nil? || @campaign.task_custom_3[:use_it] != true
			    	when "Custom4"
			    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["right"] unless @campaign.task_custom_4[:use_it].nil? || @campaign.task_custom_4[:use_it] != true
			    	when "Custom5"
			    		@campaign.engagement_tasks[:right] = params[:engagement_tasks]["right"] unless @campaign.task_custom_5[:use_it].nil? || @campaign.task_custom_5[:use_it] != true
			    	else
			    		if @campaign.engagement_tasks[:left].nil? || @campaign.engagement_tasks[:left].empty?
			    			@campaign.engagement_tasks = {}
			    		else
			    			engageleft = @campaign.engagement_tasks[:left]
			    			@campaign.engagement_tasks = {}
			    			@campaign.engagement_tasks[:left] = engageleft
			    		end
			    	end
			    else
			    	if @campaign.engagement_tasks[:left].nil? || @campaign.engagement_tasks[:left].empty?
		    			@campaign.engagement_tasks = {}
		    		else
		    			engageleft = @campaign.engagement_tasks[:left]
		    			@campaign.engagement_tasks = {}
		    			@campaign.engagement_tasks[:left] = engageleft
		    		end
			    end # Engagement Bar Right Task

			    if !params[:campaign][:share_link].nil? && params[:campaign][:share_link].match(/^(https?|ftp):\/\//)
				    if @campaign.update_attributes(params[:campaign])
				    	@campaign.shares.each do |s|
							s.url = params[:campaign][:share_link]
							s.save
						end # Update URL for all shares belonging to campaign
						@campaign.tasks.each do |t|
							t.task_1_url = Campaign.find(params[:campaign][:id]).engagement_task_left_link.to_s
							t.task_2_url = Campaign.find(params[:campaign][:id]).engagement_task_right_link.to_s
							t.save
						end # Update URLs for all tasks belonging to campaign
				        flash[:notice] = "Successfully updated."
				        #redirect_to(:action => 'edit_campaign')
				        redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
				    else
				      flash[:notice] = "Uh oh... something went wrong. Please try again."
				      redirect_to(:action => 'edit_campaign')
				    end
				else
					flash[:error] = "The Campaign Share Link must start with http:// https:// or ftp://"
					redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
				end

				# @campaign = Campaign.find(params[:campaign][:id])
				
				# unless params[:brand].blank?
				# 	@campaign.brand_id = params[:brand]
				# end

				# unless params[:category].blank?
				# 	@campaign.categories << params[:category]
				# end

				# unless params[:date_year].blank? || params[:date_month].blank? || params[:date_day].blank? || params[:date_hour].blank? || params[:date_minute].blank?
				# 	date_time = DateTime.new(params[:date_year].to_i, params[:date_month].to_i, params[:date_day].to_i, params[:date_hour].to_i, params[:date_minute].to_i, 0, "-0700")
				# 	@campaign.end_date = date_time
				# end
				
				# unless params[:campaign][:location].blank?
				# 	@location = Location.find(params[:campaign][:location])
				# 	@campaign.location_id = @location.id
				# end
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end

	 #    if @campaign.update_attributes(params[:campaign])
	 #      flash[:notice] = "Successfully updated. #{params[:brand]} b"
	 #      #redirect_to(:action => 'edit_campaign')
	 #      redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
	 #    else
	 #      flash[:notice] = "Uh oh... something went wrong. Please try again."
	 #      redirect_to(:action => 'edit_campaign')
	 #    end
	end

	def view_campaign_users
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@campaign = Campaign.find(params[:_id])
				@campaign_users = @campaign.users.order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def view_campaign_redeems
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@campaign = Campaign.find(params[:_id])
				@campaign_redeems = @campaign.redeems.order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def view_campaign_trackings
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || Rails.env.development?
				@campaign = Campaign.find(params[:_id])
				share_ids = Share.where(:campaign_id => @campaign._id).map(&:_id)

				@campaign_trackings = Tracking.where(:share_id.in => share_ids).order_by([:date, :desc])
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

	def view_campaign_tasks
		if current_user
			if current_user.account_type == 'super admin' || current_user.account_type == 'admin' || current_user.account_type == 'mini admin' || Rails.env.development?
				@campaign = Campaign.find(params[:_id])
				@total_completed_blog = @campaign.tasks.where(completed_blog: true).count
				@total_completed_facebook = @campaign.tasks.where(completed_facebook: true).count
				@total_completed_twitter = @campaign.tasks.where(completed_twitter: true).count
				@total_completed_custom1 = @campaign.custom_tasks_completed(0)
				@total_completed_custom2 = @campaign.custom_tasks_completed(1)
				@total_completed_custom3 = @campaign.custom_tasks_completed(2)
				@total_completed_custom4 = @campaign.custom_tasks_completed(3)
				@total_completed_custom5 = @campaign.custom_tasks_completed(4)
				@total_engagement_left_clicks = 0
				@total_engagement_left_uniques = 0
				@total_engagement_right_clicks = 0
				@total_engagement_right_uniques = 0
				@campaign.tasks.each do |t|
					@total_engagement_left_clicks += t.task_1_clicks
					@total_engagement_left_uniques += t.task_1_uniques
					@total_engagement_right_clicks += t.task_2_clicks
					@total_engagement_right_uniques += t.task_2_uniques
				end
				@engagement_left_clicks=[]
				@engagement_left_uniques=[]
				right_now = DateTime.now - 29.days
				for i in 0..29
					clicks = 0
					uniques = 0
					@campaign.tasks.each do |t|
						curr_task_clicks = t.task_clicks.where(:created_at.lte => right_now).where(:task_number => 1)
						curr_task_clicks.each do |tc|
							clicks += tc.views.to_i
							uniques += 1
						end
					end
					@engagement_left_clicks[i] = [i+1,clicks.to_i]
					@engagement_left_uniques[i] = [i+1,uniques.to_i]
					right_now += 24.hours
				end
				@engagement_right_clicks=[]
				@engagement_right_uniques=[]
				right_now = DateTime.now - 29.days
				for i in 0..29
					clicks = 0
					uniques = 0
					@campaign.tasks.each do |t|
						curr_task_clicks = t.task_clicks.where(:created_at.lte => right_now).where(:task_number => 2)
						curr_task_clicks.each do |tc|
							clicks += tc.views.to_i
							uniques += 1
						end
					end
					@engagement_right_clicks[i] = [i+1,clicks.to_i]
					@engagement_right_uniques[i] = [i+1,uniques.to_i]
					right_now += 24.hours
				end
			else
				redirect_to root_url
			end
		else
			redirect_to root_url
		end
	end

end
