module Wonga
  module Pantry
    class Ec2InstanceMachine
      attr_accessor :instance_state

      def termination_condition
        instance_state[:dns] == false && instance_state[:terminated] == true && instance_state[:bootstrapped] == false && instance_state[:joined] == false
      end

      state_machine :state, :initial => :initial_state do
        event :ec2_boot do
          transition :initial_state => :booting
        end

        event :ec2_booted do
          transition :booting => :booted
        end

        event :add_to_domain do
          transition :booted => :added_to_domain
        end

        event :create_dns_record do
          transition :added_to_domain => :dns_record_created
        end

        event :bootstrap do
          transition :dns_record_created => :ready
        end

        event :shutdown_now do
          transition :ready => :shutting_down
        end

        event :shutdown do
          transition :shutting_down => :shutdown
        end

        event :start_instance do
          transition :shutdown => :starting
        end

        event :started do
          transition :starting => :ready
        end

        event :termination do
          transition [:ready, :shutdown] => :terminating
        end

        event :terminated do
          transition :terminating => :terminated, :if => :termination_condition
          transition :terminating => :terminating, unless: :termination_condition
        end
      end
    end
  end
end
