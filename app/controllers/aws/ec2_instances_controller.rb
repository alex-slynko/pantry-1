class Aws::Ec2InstancesController < ApplicationController
  def new
    @ec2_instance = Ec2Instance.new
  end

  def create
  	redirect_to "/aws/ec2_instances/new"
  end
end