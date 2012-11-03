class Brand
  include Mongoid::Document
  # has_and_belongs_to_many :categories
  has_many :campaigns

  field :date, :type => DateTime
  field :last_updated, :type => DateTime
  field :name, :type => String
  field :bio, :type => String
  field :website, :type => String
  field :facebook, :type => String
  field :twitter, :type => String
  field :pinterest, :type => String
  field :gplus, :type => String

end