class InvitesController < ApplicationController
  def index
    confirm_user_logged_in
  end

  def facebook
    if confirm_user_logged_in
      if current_user.provider != "facebook"
        redirect_to '/invite'
      else
        @friendslist = current_user.get_friends
        if @friendslist.class == String
          flash[:error] = "An error occured while trying to obtain your list of friends. Is it possible you changed your Facebook password? Are you sure you have given the brandbuddee app the necessary permissions? Please check your settings and try again."
          redirect_to '/invite'
        else
            @friendslist = params[:page] ? current_user.facebook.get_page(params[:page]) : current_user.facebook.get_connections("me", "friends", {"limit" => "100"})
        end
      end
    end
  end

  def facebook_search
    if confirm_user_logged_in
      if current_user.provider != "facebook"
        redirect_to '/invite'
      else
        @allfriends = current_user.get_friends
        if @allfriends.class == String
          flash[:error] = @allfriends
          redirect_to '/invite'
        else
          if params[:query].nil? || params[:query].empty?
            flash[:error] = "Your must enter the name of a friend you wish to search for. Please try again."
            redirect_to '/invite'
          else
            query_split = params[:query].split(" ")
            @friendslist = Array.new
            @allfriends.each do |friend|
              add_me = false
              name_split = friend["name"].split(" ")
              name_split.each do |n|
                query_split.each do |q|
                  # if n.downcase == q.downcase
                  if n.downcase.start_with?(q.downcase) || n.downcase.end_with?(q.downcase)
                    add_me = true
                    break
                  end
                end
              end
              unless add_me.nil? || add_me == false
                @friendslist << {"id" => friend["id"], "name" => friend["name"]}
              end
            end
          end
        end
      end
    end
  end

  def email
    confirm_user_logged_in
  end

  def sendemail
    if confirm_user_logged_in
      if !params[:to].nil? && !params[:to].empty?
        if !current_user.first_name.nil? && !current_user.first_name.empty? && !current_user.last_name.nil? && !current_user.last_name.empty?
          subject = "Your friend #{current_user.first_name} #{current_user.last_name} says join brandbuddee"
        else
          subject = "Your friend says join brandbuddee"
        end
        if params[:message].nil? || params[:message].empty?
          message = "Hey, check out brandbuddee.com! You can discover cool things in your city, score points for sharing, and earn rewards."
        else
          message = params[:message]
        end
        if UserMailer.email_invite(params[:to], subject, message).deliver
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
      else
        flash[:error] = "Please make sure you type an email address to send the invite to."
        redirect_to '/invite/email'
      end
    end
  end

  def gmail
    if confirm_user_logged_in
      @contacts = request.env['omnicontacts.contacts']
    end
  end

  def sendgmail
    confirm_user_logged_in
  end

  def sendemail2
    if confirm_user_logged_in
      if !params[:to].nil? && !params[:to].empty?
        if !current_user.first_name.nil? && !current_user.first_name.empty? && !current_user.last_name.nil? && !current_user.last_name.empty?
          subject = "Your friend #{current_user.first_name} #{current_user.last_name} says join brandbuddee"
        else
          subject = "Your friend says join brandbuddee"
        end
        if params[:message].nil? || params[:message].empty?
          message = "Hey, check out brandbuddee.com! You can discover cool things in your city, score points for sharing, and earn rewards."
        else
          message = params[:message]
        end
        if UserMailer.email_invite(params[:to], subject, message).deliver
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
      else
        flash[:error] = "Please make sure you type an email address to send the invite to."
        redirect_to '/invite'
      end
    end # End confirm_user_logged_in
  end

  def yahoo
    if confirm_user_logged_in
      @contacts = request.env['omnicontacts.contacts']
    end
  end

  def sendyahoo
    confirm_user_logged_in
  end

  def sendemail3
    if confirm_user_logged_in
      if !params[:to].nil? && !params[:to].empty?
        if !current_user.first_name.nil? && !current_user.first_name.empty? && !current_user.last_name.nil? && !current_user.last_name.empty?
          subject = "Your friend #{current_user.first_name} #{current_user.last_name} says join brandbuddee"
        else
          subject = "Your friend says join brandbuddee"
        end
        if params[:message].nil? || params[:message].empty?
          message = "Hey, check out brandbuddee.com! You can discover cool things in your city, score points for sharing, and earn rewards."
        else
          message = params[:message]
        end
        if UserMailer.email_invite(params[:to], subject, message).deliver
          flash[:success] = "Your email has been sent!"
          redirect_to '/invite'
        else
          flash[:error] = "An error occured. Please try again."
          redirect_to '/invite'
        end
      else
        flash[:error] = "Please make sure you type an email address to send the invite to."
        redirect_to '/invite'
      end
    end
  end

  def failure
    if confirm_user_logged_in
      if params[:error_message] == "not_authorized"
        @error_message = "You must allow the brandbuddee app to have access to your #{params[:importer].humanize} contacts. Please try again."
      elsif params[:error_message] == "timeout"
        @error_message = "Too much time has passed since you were authenticated by #{params[:importer].humanize}. Please go back and try again."
      else
        @error_message = "An error occured while talking with #{params[:importer].humanize}'s servers. Please try again by clicking the \"Tell Friends on #{params[:importer].humanize}\" button."
      end
    end
  end

end
