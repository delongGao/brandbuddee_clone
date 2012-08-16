class Category
  include Mongoid::Document
  # has_and_belongs_to_many :brands
  has_and_belongs_to_many :campaigns

  field :date, :type => DateTime
  field :name, :type => String

end