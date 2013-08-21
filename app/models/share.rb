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
  field :bitly_link, :type => String

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

  def bitly_share_link
    if self.bitly_link.blank?
    	begin
      	bitly = Bitly.client
      	self.bitly_link = bitly.shorten("http://brandbuddee.com/s/#{self.link}").short_url
      	self.save!
      	self.bitly_link
      rescue Errno::ENOENT # No internet / Bad Connection
      	if Rails.env.production?
      		"http://brandbuddee.com/s/#{link}"
      	elsif Rails.env.development?
      		"http://localhost:3000/s/#{link}"
      	end
      end
    else
      self.bitly_link
    end
  end

end