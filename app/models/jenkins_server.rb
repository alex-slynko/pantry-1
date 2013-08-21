class JenkinsServer < ActiveRecord::Base
  validates :team, presence: true
  belongs_to :team
  has_many :jenkins_slaves
end
