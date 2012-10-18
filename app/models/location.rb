class Location
  include Mongoid::Document
  has_and_belongs_to_many :users
  has_many :campaigns

  field :date, :type => DateTime
  field :city, :type => String
  field :state, :type => String

  attr_accessible :date, :city, :state#, :campaign_ids

end
