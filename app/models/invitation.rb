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

end