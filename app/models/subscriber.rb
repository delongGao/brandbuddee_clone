class Subscriber
  include Mongoid::Document
  has_one :invitation, :dependent => :destroy

  field :email, :type => String
  field :date, :type => DateTime
  field :share_link, :type => String
  field :share_points, :type => Integer, :default => 0
  field :shared_emails, :type => Array, :default => []

  
  attr_accessible :email, :date, :share_link, :share_points
  
  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  validates :email, :presence => true, :length => { :maximum => 100 }, :format => EMAIL_REGEX, :confirmation => true
  
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