class User
  include Mongoid::Document
  
  field :provider, :type => String
  field :uid, :type => String
  field :date, :type => DateTime
  field :email, :type => String
  field :password_hash, :type => String
  field :password_salt, :type => String
  
  attr_accessible :username, :email, :password, :password_confirmation, :date
  
  attr_accessor :password
  before_save :encrypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true
  validates_uniqueness_of :email
  
  
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
  
  
end
