class InvitesController < ApplicationController
  def index
  end

  def twitter
  	Twitter.configure do |config|
      config.consumer_key = "z5vE0rWzBK6FpgP2dA5Z3Q"
      config.consumer_secret = "PK1rDio6DeAtvKezghHNdanc9qLrMhKxsjtXBvl6ToE"
      config.oauth_token = "210715316-mFUkB2N9uhkG4yo0WHFXFEDilPynIvn1sbI3tt7y"
      config.oauth_token_secret = "9fNn06V65RA34kIDf4SobY5Z0zh22YDH9lQA33yCz2Y"
   end
  end

  def facebook
  	
  end

  def email
  	
  end

  def sendemail
    if UserMailer.email_invite(params[:to], params[:subject], params[:message]).deliver
      respond_to do |format|
        format.html {
          flash[:success] = "Your email has been sent!"
          redirect_to '/invite/email'
        }
        format.js
      end
    else
      flash[:error] = "An error occured. Please try again."
      redirect_to '/invite/email'
    end
  end

  def tweet
    
  end

  def sendtweet
    @message = params[:message]
    @twitterid = params[:twitterid].to_i
    if @message.length == 0
      @message = params[:username] + ", check out brandbuddee.com! You can discover cool things in your city, score points for sharing, and earn rewards."
    end # if
    if @message.length > 140
      flash.now[:error] = "Your message cannot be any longer than 140 characters. Please enter a shorter message."
      render 'twitter'
    else
      if Twitter.direct_message_create(@twitterid, "#{@message}")
        respond_to do |format|
          format.html {
            flash[:success] = "Your direct message has been sent!"
            redirect_to '/invite/twitter'
          }
          format.js
        end # respond_to
      else
        flash.now[:error] = "An error occured while attempting to send your direct message. Please try again later."
        render 'index'
      end # if else
    end # if else
  end # sendtweet

  def gmail
    @contacts = request.env['omnicontacts.contacts']    
  end

  def sendgmail

  end

  def sendemail2    
    if UserMailer.email_invite(params[:to], params[:subject], params[:message]).deliver
      respond_to do |format|
        format.html {
          flash[:success] = "Your email has been sent!"
          redirect_to '/invite'
        }
        format.js
      end # respond_to      
    else
      flash[:error] = "An error occured. Please try again."
      redirect_to '/invite'
    end

    
  end

  def hotmail
    
  end

  def yahoo    
    @contacts = request.env['omnicontacts.contacts']
  end

  def sendyahoo

  end

  def sendemail3
    if UserMailer.email_invite(params[:to], params[:subject], params[:message]).deliver
      flash[:success] = "Your email has been sent!"
      redirect_to '/invite'
    else
      flash[:error] = "An error occured. Please try again."
      redirect_to '/invite'
    end
  end

  def failure
    if params[:error_message] == "not_authorized"
      @error_message = "You must allow the brandbuddee app to have access to your #{params[:importer].humanize} contacts. Please try again."
    elsif params[:error_message] == "timeout"
      @error_message = "Too much time has passed since you were authenticated by #{params[:importer].humanize}. Please go back and try again."
    else
      @error_message = "An error occured while talking with #{params[:importer].humanize}'s servers. Please try again by clicking the \"Tell Friends on #{params[:importer].humanize}\" button."
    end
  end

end
