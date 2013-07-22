class Embed
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :brand
  
  field :campaign_link, :type => String
  field :fb_page_id, :type => String
  field :fb_page_name, :type => String
  field :fb_tab_id, :type => String
end
