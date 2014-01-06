class Aws::Ec2InstancesController < ApplicationController
  before_filter :initialize_ec2_adapter, only: [:new, :create]

  def new
    @ec2_instance = Ec2Instance.new
    @ec2_instance.team_id = params[:team_id] unless params[:team_id].blank?
  end

  def create
    platform = @ec2_adapter.platform_for_ami(ec2_instance_params[:ami])
    @ec2_instance = Ec2Instance.new(
      ec2_instance_params.merge(
        {user_id: current_user.id, platform: platform}
      )
    )

    if @ec2_instance.save
      message = Wonga::Pantry::BootMessage.new(@ec2_instance).boot_message
      Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, current_user, { 'event' => "ec2_boot" }).change_state
      Wonga::Pantry::SQSSender.new(CONFIG["aws"]['boot_machine_queue_name']).send_message(message)
      flash[:notice] = "Ec2 Instance request succeeded."
      redirect_to "/aws/ec2_instances/#{@ec2_instance.id}"
    else
      flash[:error] = "Ec2 Instance request failed: #{@ec2_instance.errors.full_messages.to_sentence}"
      render :action => "new"
    end
  end

  def show
    @ec2_instance = Ec2Instance.find params[:id]
    respond_to do |format|
      format.html
      format.json { render json: @ec2_instance }
    end
  end

  def destroy
    @ec2_instance = Ec2Instance.find(params[:id])
    authorize(@ec2_instance)
    if Wonga::Pantry::Ec2Terminator.new(@ec2_instance).terminate(current_user)
      flash[:notice] = "Ec2 Instance deletion request success"
    else
      flash[:error] = "Ec2 Instance deletion request failed: #{@ec2_instance.errors.full_messages.to_sentence}"
    end
    render :show
  end

  def update
    @ec2_instance = Ec2Instance.find params[:id]
    ec2_resource = Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user)
    authorize(@ec2_instance, "#{params[:event]}?")

    if params[:event] == "shutdown_now"
      if ec2_resource.stop
        flash[:notice] = "Shutting down has started"
      else
        flash[:error] = "An error occurred when shutting down"
      end
    elsif params[:event] == "start_instance"
      if ec2_resource.start
        flash[:notice] = "Starting instance"
      else
        flash[:error] = "An error occurred while attempting to start the instance"
      end
    end

    respond_to do |format|
      format.json { render json: @ec2_instance }
      format.html do
        redirect_to request.referer
      end
    end
  end

  private

  def ec2_instance_params
    params.require(:ec2_instance).permit(:name, :team_id, :user_id, :ami, :flavor, :subnet_id, :domain, :chef_environment, :run_list, :platform, :security_group_ids => [])
  end

  def initialize_ec2_adapter
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new
  end
end

