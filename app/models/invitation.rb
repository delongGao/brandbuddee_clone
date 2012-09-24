class Invitation
  include Mongoid::Document
  belongs_to :subscriber

  field :date, :type => DateTime
  field :name, :type => String #to determine invitation source i.e. email invite, 
  field :invite_code, :type => String
  field :email, :type => String #optional email being sent to
  field :sent_by, :type => String #optional sent from field

end
