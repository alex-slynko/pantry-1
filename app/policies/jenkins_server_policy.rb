class JenkinsServerPolicy < ApplicationPolicy
  def create?
    (god_mode? || (team_member? && !maintenance_mode?)) && (@record.team.jenkins_server.nil? || @record.team.jenkins_server.new_record?)
  end

  Scope = Struct.new(:user, :scope) do
    def resolve
      scope
    end
  end
end
