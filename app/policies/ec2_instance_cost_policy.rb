class Ec2InstanceCostPolicy < ApplicationPolicy
  def index?
    @user.role == 'business_admin' || god_mode?
  end

  def show?
    index?
  end

  def show_all?
    index?
  end
end
