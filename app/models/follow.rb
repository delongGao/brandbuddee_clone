class Follow
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  field :brand_name, :type => String
  field :provider, :type => String
  field :link, :type => String
end
