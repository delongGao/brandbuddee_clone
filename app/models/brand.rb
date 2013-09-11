require 'file_size_validator'
class Brand
  include Mongoid::Document
  include ActiveModel::SecurePassword
  # has_and_belongs_to_many :categories
  has_many :campaigns
  has_many :embeds

  field :date, :type => DateTime
  field :last_updated, :type => DateTime
  field :name, :type => String
  field :bio, :type => String
  field :website, :type => String
  field :facebook, :type => String
  field :twitter, :type => String
  field :pinterest, :type => String
  field :gplus, :type => String
  field :manager_first, :type => String
  field :manager_last, :type => String
  field :phone, :type => String
  field :city, :type => String
  field :state, :type => String
  field :brand_logo
  field :provider, :type => String
  field :uid, :type => String
  field :facebook_token, :type => String
  field :facebook_expires, :type => DateTime
  field :twitter_token, :type => String
  field :twitter_secret, :type => String
  field :last_login, :type => DateTime
  field :email, :type => String
  field :password_digest, :type => String
  field :nickname, :type => String
  field :password_reset_token, :type => String
  field :password_reset_sent_at, :type => DateTime


  mount_uploader :brand_logo, BrandLogoUploader
  attr_accessible :brand_logo, :email, :password, :password_confirmation, :manager_first, :manager_last, :name, :remote_brand_logo_url, :bio, :website, :facebook, :twitter, :pinterest, :gplus, :phone, :city, :state, :nickname, :current_password

  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  TEL_REGEX = /^(\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4}))?$/
  URL_REGEX = /\b((http(s?):\/\/)([a-z0-9\-]+\.)+(MUSEUM|TRAVEL|AERO|ARPA|ASIA|EDU|GOV|MIL|MOBI|COOP|INFO|NAME|BIZ|CAT|COM|INT|JOBS|NET|ORG|PRO|TEL|A[CDEFGILMNOQRSTUWXZ]|B[ABDEFGHIJLMNORSTVWYZ]|C[ACDFGHIKLMNORUVXYZ]|D[EJKMOZ]|E[CEGHRSTU]|F[IJKMOR]|G[ABDEFGHILMNPQRSTUWY]|H[KMNRTU]|I[DELMNOQRST]|J[EMOP]|K[EGHIMNPRWYZ]|L[ABCIKRSTUVY]|M[ACDEFGHKLMNOPQRSTUVWXYZ]|N[ACEFGILOPRUZ]|OM|P[AEFGHKLMNRSTWY]|QA|R[EOSUW]|S[ABCDEGHIJKLMNORTUVYZ]|T[CDFGHJKLMNOPRTVWZ]|U[AGKMSYZ]|V[ACEGINU]|W[FS]|Y[ETU]|Z[AMW])(:[0-9]{1,5})?((\/([a-z0-9_\-\.~]*)*)?((\/)?\?[a-z0-9+_\-\.%=&amp;]*)?)?(#[a-zA-Z0-9!$&'()*+.=-_~:@\/?]*)?)/i
  validates :email, presence: true, length: { minimum: 6, maximum: 100, too_short: "must be at least 6 chars long.", too_long: "cannot be more than 100 chars long." }, format: { with: EMAIL_REGEX, message: "is not in a valid format." }
  validates_uniqueness_of :email, case_sensitive: false
  has_secure_password
  validates :password, presence: true, length: {minimum: 6, maximum: 30}, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :name, presence: true, length: { maximum: 100, too_long: "cannot be more than 100 characters" }
  validates :manager_first, presence: true, length: { maximum: 75, too_long: "cannot be more than 75 characters" }, on: :update
  validates :manager_last, presence: true, length: { maximum: 75, too_long: "cannot be more than 75 characters" }, on: :update
  validates :bio, presence: true, on: :update
  validates :website, presence: true, format: { with: URL_REGEX, message: "is not in a valid format" }, length: { maximum: 125, too_long: "cannot be more than 125 characters" }, on: :update
  validates :nickname, presence: true, format: { with: /^[a-z0-9_-]+$/, message: "must contain only lowercase letters, numbers, dashes, and underscores."}, length: { maximum: 45, too_long: "cannot be more than 45 characters long" }, on: :update
  validates :state, length: { maximum: 2, too_long: "should be abbreviated to 2 characters. It is optional."}, format: { with: /^([A-Z][A-Z])?$/, message: "should be 2 capital letters. It is optional."}
  validates :city, length: { maximum: 75, too_long: "cannot be longer than 75 characters. It is optional." }
  validates :phone, length: { maximum: 14, too_long: "cannot be longer than 14 characters. It is optional." }, format: { with: TEL_REGEX, message: "should start with the area code and be in the format: xxx.xxx.xxxx or xxx xxx xxxx. It is optional." }
  validate :change_current_password, unless: :dont_validate_current_password?
  validates :brand_logo, :file_size => { :maximum => 1.5.megabytes.to_i }

  def self.from_omniauth_twitter(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth_twitter(auth)
  end

  def self.create_from_omniauth_twitter(auth)
    brand = Brand.new
    brand.provider = auth["provider"]
    brand.uid = auth["uid"]
    brand.name = auth["info"]["name"]
    brand.twitter = auth["info"]["urls"]["Twitter"]
    brand.password_digest = auth["credentials"]["token"]
    brand.twitter_token = auth["credentials"]["token"]
    brand.twitter_secret = auth["credentials"]["secret"]
    brand.date = DateTime.now
    brand.save!(validate: false)
    brand
  end

  def self.from_omniauth_facebook(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth_facebook(auth)
  end

  def self.create_from_omniauth_facebook(auth)
    brand = Brand.new
    brand.provider = auth["provider"]
    brand.uid = auth["uid"]
    brand.name = auth["info"]["name"]
    brand.facebook = auth["info"]["urls"]["Facebook"]
    brand.password_digest = auth["credentials"]["token"]
    brand.facebook_token = auth["credentials"]["token"]
    unless auth["credentials"]["expires_at"].nil?
      brand.facebook_expires = Time.at(auth["credentials"]["expires_at"])
    else
      brand.facebook_expires = DateTime.now + 60.days
    end
    brand.date = DateTime.now
    brand.save!(validate: false)
    brand
  end

  def self.is_unique_nickname(nickname)
    nickname = nickname.downcase
    unless self.exists?(conditions: { nickname: nickname })
      return true
    else
      return false
    end
  end

  def self.is_unique_email(email)
    email = email.downcase
    unless self.exists?(conditions: { email: email })
      return true
    else
      return false
    end
  end

  def has_brand_logo?
    !self.brand_logo.blank?
  end

  def send_reset_password
    begin
      self.password_reset_token = SecureRandom.urlsafe_base64
    end while Brand.where(password_reset_token: self.password_reset_token).count > 0
    self.password_reset_sent_at = Time.zone.now
    save!
    BrandMailer.reset_password(self, "http://brandbuddee.com/").deliver
  end

  before_destroy :remember_id
  after_destroy :remove_id_directory

protected
  def remember_id
    @id = id
  end
  def remove_id_directory
    FileUtils.remove_dir("#{Rails.root}/public/brand_logo/#{@id}", :force => true)
  end

private
  def change_current_password
    return if password_digest_was.nil? || !password_digest_changed?
    unless BCrypt::Password.new(password_digest_was) == current_password
      errors.add(:current_password, "is incorrect.")
    end
  end
  def dont_validate_current_password?
    begin
      if current_password.nil?
        true
      else
        false
      end
    rescue NameError
      true
    end
  end
end