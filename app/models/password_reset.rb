class PasswordReset
  include Mongoid::Document

  field :date, :type => DateTime
  field :reset_date, :type => DateTime
  field :email, :type => String
  field :name, :type => String
  field :status, :type => Boolean, :default => false
  field :hash_code, :type => String

  attr_accessible :date, :reset_date, :email, :name, :status, :hash_code



  def self.assign_hash()
    o =  [('A'..'Z'),('a'..'z'),(1..9),(1..9)].map{|i| i.to_a}.flatten;
    @check_link = :link
    @check_link = (0...40).map{ o[rand(o.length)]}.join;
    
    if self.exists?(conditions: { invite_code: @check_link })
    else
      @link = @check_link
    end
  end

end