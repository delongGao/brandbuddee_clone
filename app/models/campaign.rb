class Campaign
  include Mongoid::Document
  has_and_belongs_to_many :users
  has_and_belongs_to_many :categories
  belongs_to :location
  belongs_to :brand
  has_many :redeems
  has_many :shares, :dependent => :destroy

  field :date, :type => DateTime
  field :last_updated, :type => DateTime
  field :title, :type => String
  field :detail, :type => String
  field :points_required, :type => Integer
  field :campaign_image
  field :limit, :type => Integer
  field :end_date, :type => DateTime
  field :status, :type => String, :default => "active"

  field :unique_page_views, :type => Integer, :default => 0
  field :page_views, :type => Integer, :default => 0
  field :share_link, :type => String
  field :link, :type => String

  field :reward, :type => String
  field :tweet, :type => String

  field :redeem_details, :type => String, :default => "This is default text for Redeem Details."

  mount_uploader :campaign_image, CampaignImageUploader
  attr_accessible :campaign_image, :date, :last_updated, :title, :detail, :points_required, :link, :limit, :share_link, :redeem_details, :location, :tweet, :reward


  def self.assign_link
    o =  [(1..9)].map{|i| i.to_a}.flatten;
    @check_link = :link
    @check_link = (0...7).map{ o[rand(o.length)]}.join;
    
    if self.exists?(conditions: { link: @check_link })
    else
      @link = @check_link
    end
  end



  before_destroy :remember_id
  after_destroy :remove_id_directory
  
  protected
  def remember_id
    @id = id
  end
  
  def remove_id_directory
    FileUtils.remove_dir("#{Rails.root}/public/campaign_image/#{@id}", :force => true)
    #FileUtils.remove_dir("http://localhost:3000/uploads/image_test/image/4f8a6da125dc9a0816000002", :force => true)
  end

end