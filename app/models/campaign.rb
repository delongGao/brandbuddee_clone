class Campaign
  include Mongoid::Document
  has_and_belongs_to_many :users
  has_and_belongs_to_many :categories
  belongs_to :location
  belongs_to :brand
  has_many :redeems
  has_many :shares, :dependent => :destroy
  has_many :tasks, :dependent => :destroy

  field :date, :type => DateTime
  field :last_updated, :type => DateTime
  field :title, :type => String
  field :detail, :type => String
  field :points_required, :type => Integer
  field :campaign_image
  field :limit, :type => Integer
  field :end_date, :type => DateTime
  field :status, :type => String, :default => "active"
  field :left, :type => Boolean, :default => true

  field :unique_page_views, :type => Integer, :default => 0
  field :page_views, :type => Integer, :default => 0
  field :share_link, :type => String
  field :link, :type => String

  field :reward, :type => String
  field :tweet, :type => String

  field :redeem_details, :type => String, :default => "This is default text for Redeem Details."

  field :task_blog_post, :type => Hash, :default => {}
  field :task_facebook, :type => Hash, :default => {}
  field :task_twitter, :type => Hash, :default => {}
  field :task_custom_1, :type => Hash, :default => {}
  field :task_custom_2, :type => Hash, :default => {}
  field :task_custom_3, :type => Hash, :default => {}
  field :task_custom_4, :type => Hash, :default => {}
  field :task_custom_5, :type => Hash, :default => {}
  field :engagement_tasks, :type => Hash, :default => {}
  field :gift_image, :type => String
  field :gift_image_two, :type => String
  field :gift_image_three, :type => String
  field :easy_prize, :type => String
  field :pinterest_clicks, :type => Integer, :default => 0
  field :twitter_clicks, :type => Integer, :default => 0
  field :facebook_clicks, :type => Integer, :default => 0
  field :tumblr_clicks, :type => Integer, :default => 0

  mount_uploader :campaign_image, CampaignImageUploader
  mount_uploader :gift_image, CampaignGiftUploader
  mount_uploader :gift_image_two, CampaignGiftUploader
  mount_uploader :gift_image_three, CampaignGiftUploader
  attr_accessible :campaign_image, :date, :last_updated, :title, :detail, :points_required, :link, :limit, :share_link, :redeem_details, :location, :tweet, :reward, :easy_prize, :gift_image, :gift_image_two, :gift_image_three, :task_blog_post


  def self.assign_link
    o =  [(1..9)].map{|i| i.to_a}.flatten;
    @check_link = :link
    @check_link = (0...7).map{ o[rand(o.length)]}.join;
    
    if self.exists?(conditions: { link: @check_link })
    else
      @link = @check_link
    end
  end

  def has_tasks?
    if self.task_blog_post=={} && self.task_facebook=={} && self.task_twitter=={} && self.task_custom_1=={} && self.task_custom_2=={} && self.task_custom_3=={} && self.task_custom_4=={} && self.task_custom_5=={}
      false
    else
      true
    end
  end

  def num_of_tasks
    num=0
    num=num+1 unless self.task_blog_post["use_it"].nil? || self.task_blog_post["use_it"].blank?
    num=num+1 unless self.task_facebook["use_it"].nil? || self.task_facebook["use_it"].blank?
    num=num+1 unless self.task_twitter["use_it"].nil? || self.task_twitter["use_it"].blank?
    num=num+1 unless self.task_custom_1["use_it"].nil? || self.task_custom_1["use_it"].blank?
    num=num+1 unless self.task_custom_2["use_it"].nil? || self.task_custom_2["use_it"].blank?
    num=num+1 unless self.task_custom_3["use_it"].nil? || self.task_custom_3["use_it"].blank?
    num=num+1 unless self.task_custom_4["use_it"].nil? || self.task_custom_4["use_it"].blank?
    num=num+1 unless self.task_custom_5["use_it"].nil? || self.task_custom_5["use_it"].blank?
    num
  end

  def engagement_task_left_link
    unless self.engagement_tasks["left"].nil? || self.engagement_tasks["left"].blank?
      case self.engagement_tasks["left"]
      when "Facebook"
        unless self.task_facebook["use_it"].nil? || self.task_facebook["use_it"].blank?
          self.task_facebook["link"]
        else
          false
        end
      when "Twitter"
        unless self.task_twitter["use_it"].nil? || self.task_twitter["use_it"].blank?
          self.task_twitter["link"]
        else
          false
        end
      when "Custom1"
        unless self.task_custom_1["use_it"].nil? || self.task_custom_1["use_it"].blank?
          self.task_custom_1["link"]
        else
          false
        end
      when "Custom2"
        unless self.task_custom_2["use_it"].nil? || self.task_custom_2["use_it"].blank?
          self.task_custom_2["link"]
        else
          false
        end
      when "Custom3"
        unless self.task_custom_3["use_it"].nil? || self.task_custom_3["use_it"].blank?
          self.task_custom_3["link"]
        else
          false
        end
      when "Custom4"
        unless self.task_custom_4["use_it"].nil? || self.task_custom_4["use_it"].blank?
          self.task_custom_4["link"]
        else
          false
        end
      when "Custom5"
        unless self.task_custom_5["use_it"].nil? || self.task_custom_5["use_it"].blank?
          self.task_custom_5["link"]
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def engagement_task_left_text
    unless self.engagement_tasks["left"].nil? || self.engagement_tasks["left"].blank?
      case self.engagement_tasks["left"]
      when "Facebook"
        unless self.task_facebook["use_it"].nil? || self.task_facebook["use_it"].blank?
          "Like this on Facebook"
        else
          false
        end
      when "Twitter"
        unless self.task_twitter["use_it"].nil? || self.task_twitter["use_it"].blank?
          "Follow this on Twitter"
        else
          false
        end
      when "Custom1"
        unless self.task_custom_1["use_it"].nil? || self.task_custom_1["use_it"].blank?
          self.task_custom_1["title"]
        else
          false
        end
      when "Custom2"
        unless self.task_custom_2["use_it"].nil? || self.task_custom_2["use_it"].blank?
          self.task_custom_2["title"]
        else
          false
        end
      when "Custom3"
        unless self.task_custom_3["use_it"].nil? || self.task_custom_3["use_it"].blank?
          self.task_custom_3["title"]
        else
          false
        end
      when "Custom4"
        unless self.task_custom_4["use_it"].nil? || self.task_custom_4["use_it"].blank?
          self.task_custom_4["title"]
        else
          false
        end
      when "Custom5"
        unless self.task_custom_5["use_it"].nil? || self.task_custom_5["use_it"].blank?
          self.task_custom_5["title"]
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def engagement_task_left_points
    unless self.engagement_tasks["left"].nil? || self.engagement_tasks["left"].blank?
      case self.engagement_tasks["left"]
      when "Facebook"
        unless self.task_facebook["points"].nil? || self.task_facebook["points"].blank?
          self.task_facebook["points"].to_i
        else
          1
        end
      when "Twitter"
        unless self.task_twitter["points"].nil? || self.task_twitter["points"].blank?
          self.task_twitter["points"].to_i
        else
          1
        end
      when "Custom1"
        unless self.task_custom_1["points"].nil? || self.task_custom_1["points"].blank?
          self.task_custom_1["points"].to_i
        else
          1
        end
      when "Custom2"
        unless self.task_custom_2["points"].nil? || self.task_custom_2["points"].blank?
          self.task_custom_2["points"].to_i
        else
          1
        end
      when "Custom3"
        unless self.task_custom_3["points"].nil? || self.task_custom_3["points"].blank?
          self.task_custom_3["points"].to_i
        else
          1
        end
      when "Custom4"
        unless self.task_custom_4["points"].nil? || self.task_custom_4["points"].blank?
          self.task_custom_4["points"].to_i
        else
          1
        end
      when "Custom5"
        unless self.task_custom_5["points"].nil? || self.task_custom_5["points"].blank?
          self.task_custom_5["points"].to_i
        else
          1
        end
      else
        1
      end
    else
      1
    end
  end

  def engagement_task_right_link
    unless self.engagement_tasks["right"].nil? || self.engagement_tasks["right"].blank?
      case self.engagement_tasks["right"]
      when "Facebook"
        unless self.task_facebook["use_it"].nil? || self.task_facebook["use_it"].blank?
          self.task_facebook["link"]
        else
          false
        end
      when "Twitter"
        unless self.task_twitter["use_it"].nil? || self.task_twitter["use_it"].blank?
          self.task_twitter["link"]
        else
          false
        end
      when "Custom1"
        unless self.task_custom_1["use_it"].nil? || self.task_custom_1["use_it"].blank?
          self.task_custom_1["link"]
        else
          false
        end
      when "Custom2"
        unless self.task_custom_2["use_it"].nil? || self.task_custom_2["use_it"].blank?
          self.task_custom_2["link"]
        else
          false
        end
      when "Custom3"
        unless self.task_custom_3["use_it"].nil? || self.task_custom_3["use_it"].blank?
          self.task_custom_3["link"]
        else
          false
        end
      when "Custom4"
        unless self.task_custom_4["use_it"].nil? || self.task_custom_4["use_it"].blank?
          self.task_custom_4["link"]
        else
          false
        end
      when "Custom5"
        unless self.task_custom_5["use_it"].nil? || self.task_custom_5["use_it"].blank?
          self.task_custom_5["link"]
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def engagement_task_right_text
    unless self.engagement_tasks["right"].nil? || self.engagement_tasks["right"].blank?
      case self.engagement_tasks["right"]
      when "Facebook"
        unless self.task_facebook["use_it"].nil? || self.task_facebook["use_it"].blank?
          "Like this on Facebook"
        else
          false
        end
      when "Twitter"
        unless self.task_twitter["use_it"].nil? || self.task_twitter["use_it"].blank?
          "Follow this on Twitter"
        else
          false
        end
      when "Custom1"
        unless self.task_custom_1["use_it"].nil? || self.task_custom_1["use_it"].blank?
          self.task_custom_1["title"]
        else
          false
        end
      when "Custom2"
        unless self.task_custom_2["use_it"].nil? || self.task_custom_2["use_it"].blank?
          self.task_custom_2["title"]
        else
          false
        end
      when "Custom3"
        unless self.task_custom_3["use_it"].nil? || self.task_custom_3["use_it"].blank?
          self.task_custom_3["title"]
        else
          false
        end
      when "Custom4"
        unless self.task_custom_4["use_it"].nil? || self.task_custom_4["use_it"].blank?
          self.task_custom_4["title"]
        else
          false
        end
      when "Custom5"
        unless self.task_custom_5["use_it"].nil? || self.task_custom_5["use_it"].blank?
          self.task_custom_5["title"]
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def engagement_task_right_points
    unless self.engagement_tasks["right"].nil? || self.engagement_tasks["right"].blank?
      case self.engagement_tasks["right"]
      when "Facebook"
        unless self.task_facebook["points"].nil? || self.task_facebook["points"].blank?
          self.task_facebook["points"].to_i
        else
          1
        end
      when "Twitter"
        unless self.task_twitter["points"].nil? || self.task_twitter["points"].blank?
          self.task_twitter["points"].to_i
        else
          1
        end
      when "Custom1"
        unless self.task_custom_1["points"].nil? || self.task_custom_1["points"].blank?
          self.task_custom_1["points"].to_i
        else
          1
        end
      when "Custom2"
        unless self.task_custom_2["points"].nil? || self.task_custom_2["points"].blank?
          self.task_custom_2["points"].to_i
        else
          1
        end
      when "Custom3"
        unless self.task_custom_3["points"].nil? || self.task_custom_3["points"].blank?
          self.task_custom_3["points"].to_i
        else
          1
        end
      when "Custom4"
        unless self.task_custom_4["points"].nil? || self.task_custom_4["points"].blank?
          self.task_custom_4["points"].to_i
        else
          1
        end
      when "Custom5"
        unless self.task_custom_5["points"].nil? || self.task_custom_5["points"].blank?
          self.task_custom_5["points"].to_i
        else
          1
        end
      else
        1
      end
    else
      1
    end
  end

  def already_has_user_share?(user)
    already = false
    self.shares.each do |s|
      if s.user_id == user.id
        already = true
      end
    end
    already
  end

  def already_has_user_task?(user)
    already = false
    self.tasks.each do |t|
      if t.user_id == user.id
        already = true
      end
    end
    already
  end

  def campaigns_and_users_task(user)
    self.tasks.where(user_id: user.id).first
  end

  def custom_tasks_completed(index)
    total = 0
    self.tasks.each do |t|
      if t.completed_custom[index]==true
        total += 1
      end
    end
    total
  end

  def get_random_image
    arr = []
    arr<<0 unless self.campaign_image.blank?
    arr<<1 unless self.gift_image.blank?
    arr<<2 unless self.gift_image_two.blank?
    arr<<3 unless self.gift_image_three.blank?
    unless arr.size < 1
      the_num = arr[Random.rand(0..arr.size-1)]
      if the_num==3
        self.gift_image_three_url(:standard).to_s # 800x800
      elsif the_num==2
        self.gift_image_two_url(:standard).to_s # 800x800
      elsif the_num==1
        self.gift_image_url(:standard).to_s # 800x800
      else # the_num==0
        self.campaign_image_url(:email).to_s # 600x300
      end
    else
      "/assets/bb-logo.png"
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
    FileUtils.remove_dir("#{Rails.root}/public/gift_image/#{@id}", :force => true)
    FileUtils.remove_dir("#{Rails.root}/public/gift_image_two/#{@id}", :force => true)
    FileUtils.remove_dir("#{Rails.root}/public/gift_image_three/#{@id}", :force => true)
    #FileUtils.remove_dir("http://localhost:3000/uploads/image_test/image/4f8a6da125dc9a0816000002", :force => true)
  end

end