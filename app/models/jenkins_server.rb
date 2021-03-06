class JenkinsServer < ActiveRecord::Base
  attr_writer :instance_role_id

  belongs_to :team
  belongs_to :ec2_instance, inverse_of: :jenkins_server
  has_many :jenkins_slaves, -> { where(removed: [false, nil]) }

  default_scope -> { eager_load(:ec2_instance).references(:ec2_instance).merge(Ec2Instance.not_terminated) }

  accepts_nested_attributes_for :ec2_instance

  validates :team, presence: true
  validates :ec2_instance, presence: true
  validate :team_cannot_own_multiple_servers, on: :create
  validates_with CIInstanceValidator

  def instance_name
    team.jenkins_host_name
  end

  def instance_role_id
    if ec2_instance
      ec2_instance.instance_role_id
    else
      @instance_role_id
    end
  end

  private

  def team_cannot_own_multiple_servers
    return unless JenkinsServer.joins(:ec2_instance).merge(Ec2Instance.not_terminated).where(team_id: team_id).exists?
    errors.add(:team, "can't own multiple servers")
  end
end
