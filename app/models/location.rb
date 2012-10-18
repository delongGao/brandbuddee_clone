class Location
  include Mongoid::Document
  has_many :campaigns
  has_and_belongs_to_many :users

  field :date, :type => DateTime
  field :city, :type => String
  field :state, :type => String

  attr_accessible :date, :city, :state

end
