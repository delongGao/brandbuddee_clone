class Invitation
  include Mongoid::Document
  belongs_to :subscriber

  field :date, :type => DateTime
  field :name, :type => String # to determine invitation source i.e. email invite
  field :invite_code, :type => String
  field :email, :type => String#, :default => "" # optional email being sent to
  field :sent_by, :type => String#, :default => "" # optional sent from field
  field :status, :type => Boolean, :default => false
  field :success_date, :type => DateTime

  attr_accessible :date, :name, :invite_code, :email, :sent_by, :status, :success_date



  def self.assign_invite_code()
    o =  [('A'..'Z'),('a'..'z'),(1..9),(1..9)].map{|i| i.to_a}.flatten;
    @check_link = :link
    @check_link = (0...25).map{ o[rand(o.length)]}.join;
    
    if self.exists?(conditions: { invite_code: @check_link })
    else
      @link = @check_link
    end
  end

end