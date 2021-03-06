class User < ActiveRecord::Base
  ROLES = %w( business_admin superadmin team_admin developer)

  has_many :team_members
  has_many :teams, through: :team_members
  has_many :ec2_instances

  validates :role, presence: true, inclusion: ROLES
  validates :username, uniqueness: true, presence: true

  before_validation :set_role, on: :create

  def self.from_omniauth(auth)
    find_by_username(auth['samaccountname'][0]) ||
      create_with_ldap(auth)
  end

  def image_url(pixels = 40)
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{pixels}&d=blank" if email
  end

  def email
    if attributes['email']
      attributes['email'].downcase
    elsif username
      "#{username}@#{CONFIG['pantry']['domain']}".downcase
    end
  end

  private

  def self.create_with_ldap(auth)
    create! do |user|
      user.username = auth['samaccountname'][0]
      user.name = auth['displayname'][0]
      user.email = auth['mail'][0] if auth['mail']
    end
  end

  def set_role
    self.role ||= 'developer'
  end
end
