class User < ActiveRecord::Base
  attr_accessible :email, :username
  has_many :team_members
  has_many :teams, through: :team_members
  
  def self.from_omniauth(auth)
    find_by_username(auth["extra"]["raw_info"].samaccountname[0]) || create_with_omniauth(auth)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.username = auth["extra"]["raw_info"].samaccountname[0]
      user.email = auth["info"]["email"]
    end
  end
end
