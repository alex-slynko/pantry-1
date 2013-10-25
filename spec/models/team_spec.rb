require 'spec_helper'

describe Team do
  subject { FactoryGirl.build(:team) }
  it { should be_valid }

  describe "without_jenkins" do
    it "finds team without jenkins server" do
      team = FactoryGirl.create(:team)
      FactoryGirl.create(:jenkins_server)
      expect(Team.count).to eq(2)
      expect(Team.without_jenkins.count).to eq(1)
    end

    it "finds team with terminated jenkins_server" do
      FactoryGirl.create(:jenkins_server, ec2_instance: FactoryGirl.create(:ec2_instance, :terminated, team: subject), team: subject)
      expect(Team.without_jenkins.count).to eq(1)
    end
  end
end
