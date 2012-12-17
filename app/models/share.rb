require 'uri'

class Share
  include Mongoid::Document
  belongs_to :campaign
  belongs_to :user
  has_many :trackings, :dependent => :destroy

  field :date, :type => DateTime
  field :link, :type => String
  field :url, :type => String
  field :unique_page_views, :type => Integer, :default => 0
  field :page_views, :type => Integer, :default => 0

  field :cookie_unique_page_views, :type => Integer, :default => 0
  field :cookie_page_views, :type => Integer, :default => 0


  def self.assign_link()
    o =  [('A'..'Z'),('a'..'z'),(1..9),(1..9)].map{|i| i.to_a}.flatten;
    @check_link = :link
    @check_link = (0...11).map{ o[rand(o.length)]}.join;
    
    if self.exists?(conditions: { link: @check_link })
    else
      @link = @check_link
    end
  end

  def self.page_view(id)
    share = Share.find(id)
    share.cookie_page_views += 1
    share.save
  end

  def self.unique_page_view(id)
    share = Share.find(id)
    share.cookie_unique_page_views += 1
    share.save
  end

  def self.get_host_without_www(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    host = URI.parse(url).host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def self.views_month(share_month)
    #share_month = self.where(:date.gt => Time.now - 1.month)
    #share_two_month = self.where(:date.gt => t - 2.month)
    share_views_month = 0

    share_month.each do |s|
      share_views_month = share_views_month + s.unique_page_views + s.trackings.size
    end

    return share_views_month

  end

end