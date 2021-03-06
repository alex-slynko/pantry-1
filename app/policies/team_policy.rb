class TeamPolicy < ApplicationPolicy
  Scope = Struct.new(:team, :scope) do
    def resolve
      scope.active
    end
  end

  def update?
    (god_mode? || user.teams.include?(record)) && active?
  end

  def deactivate?
    god_mode? && active?
  end

  def see_inactive_teams?
    god_mode?
  end

  private

  def active?
    !record.disabled?
  end
end
