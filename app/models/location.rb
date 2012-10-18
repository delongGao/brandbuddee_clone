class Location
  include Mongoid::Document
  has_many :campaigns
  has_many :users

  field :date, :type => DateTime
  field :city, :type => String
  field :state, :type => String

  attr_accessible :date, :city, :state

end
