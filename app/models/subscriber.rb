class Subscriber
  include Mongoid::Document
  has_one :invitation, :dependent => :destroy

  field :email, :type => String
  field :date, :type => DateTime
  field :share_link, :type => String
  field :share_points, :type => Integer, :default => 0
  field :shared_emails, :type => Array, :default => []
  field :consolidated, :type => Boolean, :default => false
  field :status, :type => Boolean, :default => true #subscribe status
  field :unsubscribe_hash, :type => String
  field :campaign_newsletter_1, :type => Boolean, :default => false
  field :campaign_newsletter_2, :type => Boolean, :default => false
  field :campaign_newsletter_3, :type => Boolean, :default => false

  
  attr_accessible :consolidated, :unsubscribe_hash, :campaign_newsletter_1, :campaign_newsletter_2, :campaign_newsletter_3, :email, :date, :share_link, :share_points
  
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true
  

  def self.campaign_newsletter_push(root_url)
    s = Subscriber.where(:status => true, :campaign_newsletter_3 => false)
    s.each do |subscriber|
      subscriber.campaign_newsletter_3 = true
      subscriber.save
      UserMailer.campaign_newsletter(subscriber.email, root_url).deliver
      
    end
  end

  def self.boolean_validation()
    s = Subscriber.all
    s.each do |subscriber|
      if subscriber.status == true
        subscriber.status = true
        subscriber.save
      end
      if subscriber.campaign_newsletter_3 == false
        subscriber.campaign_newsletter_3 = false
        subscriber.save
      end
    end
  end

  def self.assign_share_link(link)
    if self.exists?(conditions: { share_link: link })
    else
      o =  [('a'..'z'),(1..9),(1..9)].map{|i| i.to_a}.flatten;  
      @value = :share_link
      @value = (0...3).map{ o[rand(o.length)]}.join;
      # (0...4).map{65.+(rand(25)).chr+(rand(9)).to_s}.join
      # @value = (0...2).map.{ ('a'..'z').to_a[rand(26)]+(rand(10)).to_s }.join
    end
  end

  def self.assign_unsubscribe_hash(link)
    if self.exists?(conditions: { share_link: link })
    else
      o =  [('a'..'z'),(1..9),(1..9)].map{|i| i.to_a}.flatten;  
      @value = :share_link
      @value = (0...21).map{ o[rand(o.length)]}.join;
      # (0...4).map{65.+(rand(25)).chr+(rand(9)).to_s}.join
      # @value = (0...2).map.{ ('a'..'z').to_a[rand(26)]+(rand(10)).to_s }.join
    end
  end
  
  def self.increase_share(link, shared_email)
    self.where(share_link: link).each do |s| 
      s.share_points += 1
      s.shared_emails << shared_email
      s.save
    end
  end

  def self.check_subscriber(email)
    if self.exists?(conditions: { email: email })
      return true
    else
      return false
    end
  end

  def self.consolidate()
    users = User.all
    users.each do |u|
      if Subscriber.check_subscriber(u.email)
      else
        value = Subscriber.assign_share_link(:link)
        subscriber = Subscriber.new({:email => u.email, :date => Time.now, :share_link => value})
        subscriber.consolidated = true
        subscriber.save
      end
    end
  end

  def self.invite(id, root_url)
    new_invite_code = Invitation.assign_invite_code()
    @subscriber = Subscriber.find(id)
    @subscriber.invitation = Invitation.new(:date => Time.now, :invite_code => new_invite_code, :email => @subscriber.email)

    if @subscriber.save
      UserMailer.beta_invite(@subscriber.email, @subscriber.invitation.invite_code, root_url).deliver
      return true
    else
      return false
    end
  end
  
end