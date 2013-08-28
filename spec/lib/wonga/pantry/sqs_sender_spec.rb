require 'spec_helper'

describe Wonga::Pantry::SQSSender do
  let(:message) { double(boot_message: { 'message' => 'boot' }) }

  describe '#send_message' do 
    it "sends a message to a queue" do
      client = AWS::SQS.new.client
      resp = client.stub_for(:get_queue_url)
      resp[:queue_url] = "some_url"

      client.should_receive(:send_message) do |msg|
        JSON.parse(msg[:message_body])
        AWS::Core::Response.new
      end

      subject.send_message(message)
    end
  end
end
