require 'file_size_validator'
class User
  include Mongoid::Document
  has_and_belongs_to_many :campaigns
  belongs_to :location
  has_many :redeems, :dependent => :destroy
  has_many :shares, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :follows, :dependent => :destroy
  
  field :provider, :type => String
  field :uid, :type => String
  field :oauth_token, :type => String
  field :oauth_expires_at, :type => String

  field :date, :type => DateTime
  field :last_login, :type => DateTime
  field :last_activity, :type => DateTime
  field :email, :type => String
  field :password_hash, :type => String
  field :password_salt, :type => String

  field :account_type, :type => String
  field :brand_name, :type => String

  field :first_name, :type => String
  field :last_name, :type => String
  field :gender, :type => String
  field :phone, :type => String
  field :city, :type => String
  field :state, :type => String

  field :profile_image
  field :profile_cover

  field :website, :type => String
  field :bio, :type => String
  field :nickname, :type => String

  field :facebook_social, :type => String
  field :twitter_social, :type => String
  field :pinterest_social, :type => String

  field :follower_ids, :type => Array, :default => []
  field :following_ids, :type => Array, :default => []

  field :tumblr_token, :type => String
  field :tumblr_secret, :type => String
  
  mount_uploader :profile_image, ProfileImageUploader
  mount_uploader :profile_cover, ProfileCoverUploader
  attr_accessible :follower_ids, :following_ids, :profile_image, :profile_cover, :username, :email, :password, :password_confirmation, :date, :first_name, :last_name, :gender, :phone, :city, :state, :website, :bio, :oauth_token, :oauth_expires_at, :uid
  
  attr_accessor :password
  before_save :encrypt_password
  
  #validates_confirmation_of :password
  #validates_presence_of :password, :on => :create
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  #validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true
  validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true
  validates_uniqueness_of :email, case_sensitive: false
  #validates :profile_image, :file_size => { :maximum => 1.5.megabytes.to_i }
  #validates :profile_cover, :file_size => { :maximum => 1.5.megabytes.to_i }
  

  def self.add_following(date, user_id, current_user_id, root_url)
    user = self.find(user_id)
    current_user = self.find(current_user_id)

    unless user.follower_ids.any? {|f| f['id'] == current_user_id} || current_user.following_ids.any? {|f| f['id'] == user_id}
      user.follower_ids << {'date' => date, 'id' => current_user_id}
      current_user.following_ids << {'date' => date, 'id' => user_id}

      if user.save && current_user.save
        UserMailer.follow(user, current_user, root_url).deliver
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.remove_follower(user_id, current_user_id)
    user = self.find(user_id)
    current_user = self.find(current_user_id)
    #user.follower_ids.delete({'date' => date, 'id' => })
    user.follower_ids.delete_if {|x| x["id"] == current_user_id}
    current_user.following_ids.delete_if {|x| x["id"] == user_id}
    #current_user.following_ids.delete({'date' => date, 'id' => user_id})
    
    if user.save && current_user.save
      return true
    else
      return false
    end
  end

  def self.validates_email_uniqueness(email)
    if self.exists?(conditions: { email: email })
      return true
    else
      return false
    end
  end

  def self.uid_check(uid)
    if self.exists?(conditions: { uid: uid })
      exists = self.where(:uid => uid).first
      unless exists.oauth_token.nil?
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.create_with_omniauth(auth, time_now)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.oauth_token = auth["credentials"]["token"]
      user.oauth_expires_at = auth["credentials"]["expires_at"]
      user.date = time_now
      user.first_name = auth["extra"]["raw_info"]["first_name"]
      user.last_name = auth["extra"]["raw_info"]["last_name"]
      user.email = auth["info"]["email"]
      #user.image = auth["info"]["image"]
      #user.remote_profile_image_url = auth["info"]["image"]
      user.remote_profile_image_url = "http://graph.facebook.com/#{auth["uid"]}/picture?type=large"
      user.city = auth["info"]["location"]
      user.facebook_social = auth["info"]["nickname"]
    end
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
  end

  def self.update_with_omniauth(auth, user)
    if self.uid_check(auth["uid"])
      if auth["provider"]=="facebook" && user.provider=="facebook"
        user.update_attributes!(
          oauth_token: auth["credentials"]["token"],
          oauth_expires_at: auth["credentials"]["expires_at"]
        )
        return true
      elsif auth["provider"]=="twitter" && user.provider=="twitter"
        user.update_attributes!(
          oauth_token: auth["credentials"]["token"]
        )
        return true
      else
      	return false
      end
    else
      if auth["provider"]=="facebook"
        user.update_attributes!(
          uid: auth["uid"],
          oauth_token: auth["credentials"]["token"],
          oauth_expires_at: auth["credentials"]["expires_at"]
        )
        user.provider = auth["provider"]
        user.save!
      else
        user.update_attributes!(
          uid: auth["uid"],
          oauth_token: auth["credentials"]["token"]
        )
        user.provider = auth["provider"]
        user.save!
      end
      return true
    end
  end

  def self.create_with_omniauth_twitter(auth, time_now, email)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.date = time_now
      user.first_name = auth["extra"]["raw_info"]["first_name"]
      user.last_name = auth["extra"]["raw_info"]["last_name"]
      user.email = email
      #user.image = auth["info"]["image"]
      #user.remote_profile_image_url = auth["info"]["image"]
      user.remote_profile_image_url = "http://graph.facebook.com/#{auth["uid"]}/picture?type=large"
      user.city = auth["info"]["location"]
      user.facebook_social = auth["info"]["nickname"]
    end
  end
  
  def self.authenticate(email, password)
    # find user via email only
    # user = self.where(email: email, username: email).first
    
    # find user via email or username
    # user = self.any_of({ email: email }, { username: email }).first
    user = self.any_of({ email: email }).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def get_friends
    facebook.get_connection("me", "friends")
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    e.to_s
  end


  before_destroy :remember_id
  after_destroy :remove_id_directory
  
  protected
  def remember_id
    @id = id
  end
  
  def remove_id_directory
    FileUtils.remove_dir("#{Rails.root}/public/profile_image/#{@id}", :force => true)
    FileUtils.remove_dir("#{Rails.root}/public/profile_cover/#{@id}", :force => true)
    #FileUtils.remove_dir("http://localhost:3000/uploads/image_test/image/4f8a6da125dc9a0816000002", :force => true)
  end
  
end
