class User
  include Mongoid::Document
  has_and_belongs_to_many :campaigns
  belongs_to :locations
  has_many :redeems
  has_many :shares
  
  field :provider, :type => String
  field :uid, :type => String
  field :date, :type => DateTime
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

  field :website, :type => String
  field :bio, :type => String
  field :nickname, :type => String

  field :facebook, :type => String
  field :twitter, :type => String
  field :pinterest, :type => String
  
  mount_uploader :profile_image, ProfileImageUploader
  attr_accessible :profile_image, :username, :email, :password, :password_confirmation, :date, :first_name, :last_name, :gender, :phone, :city, :state, :website, :bio
  
  attr_accessor :password
  before_save :encrypt_password
  
  #validates_confirmation_of :password
  #validates_presence_of :password, :on => :create
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  #validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true
  validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true
  validates_uniqueness_of :email
  

  def self.create_with_omniauth(auth, time_now)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.date = time_now
      user.first_name = auth["extra"]["raw_info"]["first_name"]
      user.last_name = auth["extra"]["raw_info"]["last_name"]
      if auth["info"]["email"].nil?
        user.email = 'email@email.com'
      else
        user.email = auth["info"]["email"]
      end
      #user.image = auth["info"]["image"]
      #user.remote_profile_image_url = auth["info"]["image"]
      user.remote_profile_image_url = "http://graph.facebook.com/#{auth["uid"]}/picture?type=large"
      user.city = auth["info"]["location"]
      user.facebook = auth["info"]["nickname"]
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


  before_destroy :remember_id
  after_destroy :remove_id_directory
  
  protected
  def remember_id
    @id = id
  end
  
  def remove_id_directory
    FileUtils.remove_dir("#{Rails.root}/public/profile_image/user/#{@id}", :force => true)
    #FileUtils.remove_dir("http://localhost:3000/uploads/image_test/image/4f8a6da125dc9a0816000002", :force => true)
  end
  
end
