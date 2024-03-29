class AdminController < ApplicationController
	before_filter :require_super_admin_account, only: [:users, :locations, :location_new, :location_delete, :redeems, :categories, :category_new, :category_delete]
	before_filter :require_admin_account, only: [:campaign_delete, :campaign_new_index, :campaign_new, :brand_new_index, :brand_new, :brand_edit, :brand_update, :brand_delete, :update_campaign, :view_campaign_trackings, :campaign_apply_crop, :give_old_brand_profile, :convert_old_account_to_new]
	before_filter :require_mini_admin_account, only: [:index, :campaigns, :brands, :view_campaign, :edit_campaign, :view_campaign_users, :view_campaign_redeems, :view_campaign_tasks]

	def index
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
	end

	def users
		@users = User.all.order_by([:date, :desc])
	end

	def campaigns
		@campaigns = Campaign.all.order_by([:date, :desc])
		@location_all = Location.all.order_by([:name, :asc])
		@category_all = Category.all.order_by([:name, :asc])
		@brand_all = Brand.all.order_by([:name, :asc])
		@link = Campaign.assign_link()
	end

	def campaign_delete
		@campaign = Campaign.find(params[:_id])
		@campaign.destroy
		flash[:notice] = "#{@campaign.title} campaign Destroyed"
		redirect_to(:action => 'campaigns')
	end

	def campaign_new_index
		@campaign = Campaign.new
		@link = Campaign.assign_link()
		@location_all = Location.all.order_by([:name, :asc])
		@brand_all = Brand.all.order_by([:name, :asc])
		@category_all = Category.all.order_by([:name, :asc])
	end

	def campaign_new
		if params[:brands].nil? || params[:brands].empty?
			flash[:error] = "ERROR: You forgot to select a brand!!!"
			redirect_to "/admin/campaign/new-index"
	    elsif params[:categories].nil? || params[:categories].empty?
	    	flash[:error] = "ERROR: You forgot to select a category!!!"
	    	redirect_to "/admin/campaign/new-index"
	    else
	    	begin
				@brand = Brand.find(params[:brands])
		    	@campaign = @brand.campaigns.create!(params[:campaign])

		    	unless params[:date_end].blank?
		    		date_time_str = params[:date_end].to_s[2..-3]
		    		@campaign.end_date = DateTime.parse(date_time_str).utc
		    	else
		    		@campaign.end_date = DateTime.now + 30.days
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
			    if !params[:task_yelp].nil? && params[:task_yelp]["0"] == "true"
			    	if !params[:task_yelp]["1"].empty? && !params[:task_yelp]["2"].empty? && !params[:task_yelp]["3"].empty?
			    		@campaign.task_yelp[:use_it] = true
			    		@campaign.task_yelp[:title] = params[:task_yelp]["1"]
			    		@campaign.task_yelp[:description] = params[:task_yelp]["2"]
			    		@campaign.task_yelp[:points] = params[:task_yelp]["3"].to_i
			    	else
			    		flash[:error] = "WARNING: Unable to add Task: Write A Yelp Review. Make sure you fill out ALL fields."
			    	end
			    end # Yelp Review Task
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
			    if !params[:task_email_subscription].nil? && params[:task_email_subscription]["0"] == "true"
			    	if !params[:task_email_subscription]["1"].empty? && !params[:task_email_subscription]["2"].empty? && !params[:task_email_subscription]["3"].empty?
			    		@campaign.task_email_subscription[:use_it] = true
			    		@campaign.task_email_subscription[:title] = params[:task_email_subscription]["1"]
			    		@campaign.task_email_subscription[:description] = params[:task_email_subscription]["2"]
						@campaign.task_email_subscription[:points] = params[:task_email_subscription]["3"].to_i
					else
						flash[:error] = "WARNING: Unable to add Task: Subscribe An Email Newsletter. Make sure you fill out ALL fields."
					end
				end # Email Subscription Task
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

			    if !params[:campaign][:share_link].nil? && params[:campaign][:share_link].match(/^(https?|ftp):\/\//)
				    if @campaign.save
				    	if params[:campaign][:campaign_image].present?
				    		render :campaign_image_cropper
				    	else
				    		@campaign.destroy
				      		flash[:notice] = "You must upload a campaign image"
				      		redirect_to(:action => 'campaigns')
				      	end
				    else
				      flash[:notice] = "There was an ERROR saving. Please try again."
				      render "campaign_new_index"
				    end
				else
					@campaign.destroy
					flash[:error] = "ERROR: Campaign Share Link must start with http:// https:// or ftp://"
					redirect_to "/admin/campaign/new-index"
				end
			rescue Mongoid::Errors::Validations
				if params[:campaign][:redeem_name].blank? || params[:campaign][:redeem_name].length > 60
					flash[:error] = "Redeem Contact Name is Required and cannot be longer than 60 characters"
				elsif params[:campaign][:redeem_email].blank? || params[:campaign][:redeem_email].length < 6 || params[:campaign][:redeem_email].length > 100 || !params[:campaign][:redeem_email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
					flash[:error] = "Redeem Contact Email is Required, must be between 6-100 characters, and must be in a valid format"
				elsif params[:campaign][:redeem_value].blank? || !params[:campaign][:redeem_value].match(/^\$\d+\.?\d{2}?+$/)
					flash[:error] = "Redeem Value of Primary Reward is Required and must be in the format $1234.67"
				elsif params[:campaign][:redeem_expires].blank?
					flash[:error] = "Redeem Expiration Date is Required"
				elsif !params[:campaign][:redeem_special_circ].blank? && params[:campaign][:redeem_special_circ].length > 5000
					flash[:error] = "Redeem Special Circumstances is OPTIONAL, but if used, cannot be longer than 5000 characters."
				else
					flash[:error] = "One or more fields that are required were left blank. Please make sure you fill out all fields and try again."
				end
				redirect_to "/admin/campaign/new-index"
			end
		end
	end

	def locations
		@locations = Location.all.order_by([:date, :desc])
	end

	def location_new
		@location = Location.create!(params[:location])
    if @location.save
      flash[:notice] = "Location successfully created"
      redirect_to(:action => 'locations')
    else
      flash[:notice] = "Uh oh"
    end
	end

	def location_delete
		@location = Location.find(params[:_id])
		@location.destroy
		flash[:notice] = "#{@location.city} Location Destroyed"
		redirect_to(:action => 'locations')
	end

	def redeems
		@redeems = Redeem.all.order_by([:date, :desc])
	end

	def categories
		@categories = Category.all.order_by([:date, :desc])
	end

	def category_new
		@category = Category.create!(params[:category])
    if @category.save
      flash[:notice] = "Category successfully created"
      redirect_to(:action => 'categories')
    else
      flash[:notice] = "Uh oh"
    end
	end

	def category_delete
		@category = Category.find(params[:_id])
    @category.destroy
    flash[:notice] = "#{@category.name} Category Destroyed"
    redirect_to(:action => 'categories')
	end

	def brands
		@brands = Brand.all.order_by([:date, :desc])
	end

	def brand_new_index
		@brand = Brand.new
	end

	def brand_new
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
	end

	def brand_edit
		@brand = Brand.find(params[:_id])
	end

	def brand_update
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
	end

	def brand_delete
		@brand = Brand.find(params[:_id])
    @brand.destroy
    flash[:notice] = "#{@brand.name} brand Destroyed"
    redirect_to(:action => 'brands')
	end

	def view_campaign
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
		@total_linkedin_clicks = @campaign.linkedin_clicks
		@total_google_plus_clicks = @campaign.google_plus_clicks
		@total_social_clicks = @total_pinterest_clicks + @total_twitter_clicks + @total_facebook_clicks + @total_tumblr_clicks + @total_linkedin_clicks + @total_google_plus_clicks
	end

	def edit_campaign
		@category_all = Category.all.order_by([:name, :asc])
  	@brand_all = Brand.all.order_by([:name, :asc])
  	@location_all = Location.all.order_by([:city, :desc])
		@campaign = Campaign.find(params[:_id])
	end

	def update_campaign
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

		unless params[:date_end].blank?
  			date_time_str = params[:date_end].to_s[2..-3]
  			@campaign.end_date = DateTime.parse(date_time_str).utc
	  	else
	  		@campaign.end_date = DateTime.now + 30.days
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

	    if !params[:task_yelp].nil? && params[:task_yelp]["0"] == "UPDATE"
	    	if !params[:task_yelp]["1"].empty? && !params[:task_yelp]["2"].empty? && !params[:task_yelp]["3"].empty?
	    		@campaign.task_yelp[:use_it] = true
	    		@campaign.task_yelp[:title] = params[:task_yelp]["1"]
	    		@campaign.task_yelp[:description] = params[:task_yelp]["2"]
	    		@campaign.task_yelp[:points] = params[:task_yelp]["3"].to_i
	    	else
	    		flash[:error] = "WARNING: Unable to add Task: Write A Yelp Review. Make sure you fill out ALL fields."
	    	end
	    else
	    	@campaign.task_yelp = {}
	    end # Yelp Review Task

	    if !params[:task_email_subscription].nil? && params[:task_email_subscription]["0"] == "UPDATE"
	    	if !params[:task_email_subscription]["1"].empty? && !params[:task_email_subscription]["2"].empty? && !params[:task_email_subscription]["3"].empty?
	    		@campaign.task_email_subscription[:use_it] = true
	    		@campaign.task_email_subscription[:title] = params[:task_email_subscription]["1"]
	    		@campaign.task_email_subscription[:description] = params[:task_email_subscription]["2"]
	    		@campaign.task_email_subscription[:points] = params[:task_email_subscription]["3"].to_i
	    	else
	    		flash[:error] = "WARNING: Unable to add Task: Email Subscription. Make sure you fill out ALL fields."
	    	end
	    else
	    	@campaign.task_yelp = {}
	    end # Email Subscription Task

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
		    	unless @campaign.redeem_details.blank?
		    		unless params[:campaign][:redeem_name].blank? || params[:campaign][:redeem_email].blank? || params[:campaign][:redeem_value].blank?|| params[:campaign][:redeem_expires].blank?
		    			@campaign.redeem_details = nil
		    			@campaign.save!
		    		end
		    	end
		    	@campaign.shares.each do |s|
						s.url = params[:campaign][:share_link]
						s.save
					end # Update URL for all shares belonging to campaign
					@campaign.tasks.each do |t|
						t.task_1_url = Campaign.find(params[:campaign][:id]).engagement_task_left_link.to_s
						t.task_2_url = Campaign.find(params[:campaign][:id]).engagement_task_right_link.to_s
						t.save
					end # Update URLs for all tasks belonging to campaign
					if params[:campaign][:campaign_image].present?
						render :campaign_image_cropper
					else
		        flash[:notice] = "Successfully updated."
		        #redirect_to(:action => 'edit_campaign')
		        redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
		      end
		    else
		      if params[:campaign][:redeem_name].blank? || params[:campaign][:redeem_name].length > 60
						flash[:error] = "Redeem Contact Name is Required and cannot be longer than 60 characters"
					elsif params[:campaign][:redeem_email].blank? || params[:campaign][:redeem_email].length < 6 || params[:campaign][:redeem_email].length > 100 || !params[:campaign][:redeem_email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
						flash[:error] = "Redeem Contact Email is Required, must be between 6-100 characters, and must be in a valid format"
					elsif params[:campaign][:redeem_value].blank? || !params[:campaign][:redeem_value].match(/^\$\d+\.?\d{2}?+$/)
						flash[:error] = "Redeem Value of Primary Reward is Required and must be in the format $1234.67"
					elsif params[:campaign][:redeem_expires].blank?
						flash[:error] = "Redeem Expiration Date is Required"
					elsif !params[:campaign][:redeem_special_circ].blank? && params[:campaign][:redeem_special_circ].length > 5000
						flash[:error] = "Redeem Special Circumstances is OPTIONAL, but if used, cannot be longer than 5000 characters."
					else
						flash[:error] = "One or more fields that are required were left blank. Please make sure you fill out all fields and try again."
					end
		      redirect_to "/admin/campaign/edit?_id=#{params[:campaign][:id]}"
		    end
			else
				flash[:error] = "The Campaign Share Link must start with http:// https:// or ftp://"
				redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
			end
	end

	def view_campaign_users
		@campaign = Campaign.find(params[:_id])
		@campaign_users = @campaign.users.order_by([:date, :desc])
	end

	def view_campaign_redeems
		@campaign = Campaign.find(params[:_id])
		@campaign_redeems = @campaign.redeems.order_by([:date, :desc])
	end

	def view_campaign_trackings
		@campaign = Campaign.find(params[:_id])
		share_ids = Share.where(:campaign_id => @campaign._id).map(&:_id)

		@campaign_trackings = Tracking.where(:share_id.in => share_ids).order_by([:date, :desc])
	end

	def view_campaign_tasks
		@campaign = Campaign.find(params[:_id])
		@total_completed_blog = @campaign.tasks.where(completed_blog: true).count
		@total_completed_email = @campaign.tasks.where(completed_email: true).count
		@total_completed_yelp = @campaign.tasks.where(completed_yelp: true).count
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
	end

	def campaign_apply_crop
		unless params[:campaign_id].nil?
			@campaign = Campaign.find(params[:campaign_id])
			unless @campaign.nil?
				@campaign.crop_x = params[:campaign][:crop_x]
				@campaign.crop_y = params[:campaign][:crop_y]
				@campaign.crop_w = params[:campaign][:crop_w]
				@campaign.crop_h = params[:campaign][:crop_h]
				if @campaign.save
					if @campaign.crop_campaign_image
						flash[:notice] = "Your campaign image has been cropped!!!"
						redirect_to "/admin/campaigns"
					else
						flash[:error] = "An error occurred while trying to crop the campaign image. Please try again..."
						redirect_to "/admin/campaigns"
					end
				else
					flash[:error] = "An error occurred while trying to crop the campaign image. Please try again..."
					redirect_to "/admin/campaigns"
				end
			else
				flash[:error] = "An error occurred while trying to find the campaign to update. Please try again."
				redirect_to "/admin/campaign/new-index"
			end
		else
			flash[:error] = "An error occurred while trying to find the campaign to update. Please try again."
			redirect_to "/admin/campaign/new-index"
		end
	end

	def convert_old_account_to_new
		unless params[:brands].blank?
			@brand ||= Brand.find(params[:brands])
		else
			flash[:error] = "You must select a brand!"
			redirect_to "/admin/brands/select-brand-to-convert"
		end
	end

	def give_old_brand_profile
		unless params[:brand].blank?
			@brand = Brand.find(params[:brand_id])
			unless params[:brand][:password].blank? || !params[:brand][:password].length.between?(6,30)
				unless params[:brand][:password_confirmation].blank? || params[:brand][:password] != params[:brand][:password_confirmation]
					unless params[:brand][:nickname].blank? || !params[:brand][:nickname].match(/^[a-z0-9_-]+$/) || params[:brand][:nickname].length > 45
						unless params[:brand][:email].blank? || params[:brand][:email].length < 6 || params[:brand][:email].length > 100 || !params[:brand][:email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
							if Brand.first(conditions: {nickname: /^#{params[:brand][:nickname]}$/i}).nil?
								if Brand.first(conditions: {email: /^#{params[:brand][:email]}$/i}).nil?
									if @brand.update_attributes(params[:brand])
										@brand.nickname.downcase!
										@brand.email.downcase!
										@brand.provider = "email"
										@brand.save(validate: false)
										flash[:success] = "The Brand: \"#{@brand.name}\" has been given a profile, nickname, and an email/password login."
										redirect_to "/admin/brands/select-brand-to-convert"
									else
										render "convert_old_account_to_new"
									end
								else
									@brand.errors.add(:email, "has already been taken. Please choose another.")
									render "convert_old_account_to_new"
								end
							else
								@brand.errors.add(:nickname, "has already been taken. Please choose another one.")
								render "convert_old_account_to_new"
							end
						else
							@brand.errors.add(:email, "is not in the correct format. Should be: ______@______.___. Between 6-100 characters please.")
							render "convert_old_account_to_new"
						end
					else
						@brand.errors.add(:nickname, "is not in the correct format. Only lowercase letters, numbers, dashes, and underscores please. Between 1-45 characters")
						render "convert_old_account_to_new"
					end
				else
					@brand.errors.add(:password_confirmation, "does not match the password.")
					render "convert_old_account_to_new"
				end
			else
				@brand.errors.add(:password, "must be between 6-30 characters in length.")
				render "convert_old_account_to_new"
			end
		else
			flash[:error] = "When converting a brand, you must fill out ALL of the form"
			redirect_to "/admin/brands/select-brand-to-convert"
		end
	end

end
