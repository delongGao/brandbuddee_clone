class CampaignController < ApplicationController

	def index
		params_campaign = params[:campaign].downcase
		campaign = Campaign.where(:link => params_campaign).first
		@campaigns_else = Campaign.all(:limit => 3).order_by([:date, :desc])
		if campaign.present?
		  @campaign = campaign
		  # @gallery = user.images.order_by([:date, :desc])
		  # @images = Image.all.order_by([:date, :desc])
		end
		if campaign.nil?
		  redirect_to root_url
		end
	end

	def activate_campaign
		@campaign = Campaign.find(params[:_c])
		@campaign.user_ids << current_user.id
		share_link = Share.assign_link
		@campaign.shares.create!(date: Time.now, link: share_link, user_id: current_user.id, campaign_id: @campaign.id, url: @campaign.share_link )
		#@campaign.shares.user_id = current_user.id
		#@campaign.shares.campaign_id = @campaign.id

		url = root_url + "campaign/" + @campaign.link
		if @campaign.save
	      flash[:notice] = "Campaign Activated"
	      redirect_to url
	    else
	      flash[:notice] = "Uh oh"
	      redirect_to url
	    end
	end

	def share
		share = Share.where(:link => params[:share]).first
		if share.present?
			Share.page_view(share.id)

			c = cookies[share.id]
			if c == share.id
			elsif c.nil?
			  cookies[share.id] = share.id
			  Share.unique_page_view(share.id)
			end

			share_update = Share.find(share.id)
			user_share = share_update.user_id
			if share_update.unique_page_views == share_update.campaign.points_required
				redeem_check = Redeem.where(:user_id => user_share, :campaign_id => share_update.campaign_id).first
				if redeem_check.nil?
					left = share_update.campaign.limit - share_update.campaign.redeems.size
					unless left == 0
						redeem_code = Redeem.assign_redeem_code()
						@redeem = Redeem.create!(date: Time.now, redeem_code: redeem_code, campaign_id: share_update.campaign_id, user_id: share_update.user_id )
						@redeem.save
					end
				end
			end

			#redirect to share link
			share_link = share.url
			redirect_to share_link
		end
		if share.nil?
		  redirect_to root_url
		end
	end

	def edit_campaign
		@category_all = Category.all.order_by([:date, :desc])
    	@brand_all = Brand.all.order_by([:date, :desc])

		@campaign = Campaign.find(params[:_id])
	end

	def update_campaign
		@campaign = Campaign.find(params[:campaign][:id])
	    if @campaign.update_attributes(params[:campaign])
	      flash[:notice] = "Successfully updated."
	      #redirect_to(:action => 'edit_campaign')
	      redirect_to "#{root_url}admin/campaign/edit?_id=#{params[:campaign][:id]}"
	    else
	      flash[:notice] = "Uh oh... something went wrong. Please try again."
	      redirect_to(:action => 'edit_campaign')
	    end
	end

end
