class Redeem
  include Mongoid::Document
  belongs_to :campaign
  belongs_to :user

  field :date, :type => DateTime
  field :redeem_code, :type => String
  field :status, :type => Boolean, :default => false



  def self.assign_redeem_code()
    o =  [('A'..'Z'),('a'..'z'),(1..9),(1..9)].map{|i| i.to_a}.flatten;
    @check_link = :link
    @check_link = (0...20).map{ o[rand(o.length)]}.join;
    
    if self.exists?(conditions: { redeem_code: @check_link })
    else
      @link = @check_link
    end
  end

end