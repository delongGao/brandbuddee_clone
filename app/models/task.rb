class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :task_clicks, :dependent => :destroy
  belongs_to :campaign
  belongs_to :user
  field :task_1_url, :type => String
  field :task_2_url, :type => String
  field :task_1_clicks, :type => Integer, :default => 0
  field :task_2_clicks, :type => Integer, :default => 0
  field :task_1_uniques, :type => Integer, :default => 0
  field :task_2_uniques, :type => Integer, :default => 0
  field :completed_custom, :type => Array, :default => [false,false,false,false,false]
  field :completed_blog, :type => Boolean, :default => false
  field :completed_facebook, :type => Boolean, :default => false
  field :completed_twitter, :type => Boolean, :default => false
  field :blog_post_url, :type => String
  field :completed_points, :type => Integer, :default => 0
end
