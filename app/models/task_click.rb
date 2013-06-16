class TaskClick
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :task
  field :ip_address, :type => String
  field :views, :type => Integer, :default => 1
  field :task_number, :type => Integer
end
