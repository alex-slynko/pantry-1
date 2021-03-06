class Wonga::Pantry::Ec2Resource
  def initialize(instance,
                  user = nil,
                  start_publisher = Wonga::Pantry::SNSPublisher.new(CONFIG['aws']['ec2_instance_start_topic_arn']),
                  stop_publisher  = Wonga::Pantry::SNSPublisher.new(CONFIG['aws']['ec2_instance_stop_topic_arn']))
    @start_publisher  = start_publisher
    @stop_publisher   = stop_publisher
    @ec2_instance     = instance
    @user             = user
  end

  def stop
    change('shutdown_now', @stop_publisher)
  end

  def stop_automatically
    change('shutdown_now_automatically', @stop_publisher)
  end

  def start
    change('start_instance', @start_publisher)
  end

  def start_automatically
    change('start_instance_automatically', @start_publisher)
  end

  def terminate(sns = Wonga::Pantry::SNSPublisher.new(CONFIG['aws']['ec2_instance_delete_topic_arn']))
    change('termination', sns, base_message.merge(remove_volumes: true))
  end

  def out_of_band_cleanup(sns = Wonga::Pantry::SNSPublisher.new(CONFIG['aws']['ec2_instance_delete_topic_arn']))
    change('out_of_band_cleanup', sns)
  end

  def boot(publisher = Wonga::Pantry::SNSPublisher.new(CONFIG['aws']['ec2_instance_boot_topic_arn']))
    return unless state_machine('ec2_boot').change_state
    publisher.publish_message(Wonga::Pantry::BootMessage.new.boot_message(@ec2_instance))
    true
  end

  def resize(size, sns = Wonga::Pantry::SNSPublisher.new(CONFIG['aws']['ec2_instance_resize_topic_arn']))
    # TODO: move this check in policies
    unless CONFIG['aws']['ebs'].key?(size)
      @ec2_instance.errors.add(:flavor, 'not supported')
      return
    end

    change('resize', sns, base_message.merge(flavor: size))
  end

  def change(event, publisher, message = base_message)
    return unless state_machine(event).change_state
    publisher.publish_message(message)
    true
  end

  private

  def state_machine(event)
    Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, 'event' => event)
  end

  def base_message
    user_id = @user.id if @user
    {
      hostname:             @ec2_instance.name,
      domain:               @ec2_instance.domain,
      instance_id:          @ec2_instance.instance_id,
      id:                   @ec2_instance.id,
      user_id:              user_id
    }
  end
end
