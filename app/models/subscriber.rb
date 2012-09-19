class Subscriber
  include Mongoid::Document

  field :email, :type=>String
  field :date, :type=>Time
  field :share_link, :type=>String
  field :share_points, :type=>Integer, :default=>0
  field :shared_emails, :type=>Array, :default=>[]
  
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
  
end
