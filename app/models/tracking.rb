class Tracking
  include Mongoid::Document
  belongs_to :share

  field :date, :type => DateTime
  field :ip_address, :type => String
  field :views, :type => Integer, :default => 1


  def self.validates_ip_uniqueness(ip, share)
    if self.exists?(conditions: { ip_address: ip, share_id: share.id })
      return true
    else
      return false
    end
  end

  def self.view(id)
    tracking = self.find(id)
    tracking.views += 1
    tracking.save
  end

end