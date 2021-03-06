require 'spec_helper'

RSpec.describe Wonga::Pantry::Costs do
  let(:bill_date) { Time.zone.today.prev_month.end_of_month }
  let(:team) { FactoryGirl.create(:team) }
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }

  subject { Wonga::Pantry::Costs.new(bill_date) }

  describe '#costs_per_team' do
    it 'returns array of hashes with total costs for current bill date only' do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date + 1, ec2_instance: ec2_instance, cost: 50)
      result = subject.costs_per_team.first
      expect(result.id).to eq team.id
      expect(result.name).to eq team.name
      expect(result.costs).to eq 100
    end

    it 'returns array of hashes with total costs for all instances' do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: FactoryGirl.create(:ec2_instance, team: team), cost: 50)
      result = subject.costs_per_team.first
      expect(result.id).to eq team.id
      expect(result.name).to eq team.name
      expect(result.costs).to eq 150
    end

    context 'when team is disabled' do
      let(:team) { FactoryGirl.create(:team, disabled: true) }

      it 'returns array of hashes with total costs' do
        FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
        result = subject.costs_per_team.first
        expect(result.id).to eq team.id
        expect(result.name).to eq team.name
      end
    end
  end

  describe '#costs_details_per_team' do
    it 'returns the instances with their cost, providing a date and the team id' do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: FactoryGirl.create(:ec2_instance, team: team), cost: 50)
      result = subject.costs_details_per_team(team.id)
      expect(result.map(&:cost)).to match_array([50, 100])
    end

    it 'returns the costs of team instances only' do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: FactoryGirl.create(:ec2_instance), cost: 50)
      result = subject.costs_details_per_team(team.id)
      expect(result.map(&:cost)).to match_array([100])
    end

    it 'returns the costs for current bill date only' do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date + 1, ec2_instance: FactoryGirl.create(:ec2_instance, team: team), cost: 50)
      result = subject.costs_details_per_team(team.id)
      expect(result.map(&:cost)).to match_array([100])
    end
  end

  describe '#costs_details' do
    it 'returns the instances with their cost, providing a date and the team id' do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: FactoryGirl.create(:ec2_instance), cost: 50)
      result = subject.costs_details
      expect(result.map(&:cost)).to match_array([50, 100])
    end

    it 'returns the costs for current bill date only' do
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date, ec2_instance: ec2_instance, cost: 100)
      FactoryGirl.create(:ec2_instance_cost, bill_date: bill_date + 1, ec2_instance: FactoryGirl.create(:ec2_instance, team: team), cost: 50)
      result = subject.costs_details
      expect(result.map(&:cost)).to match_array([100])
    end
  end

  describe '#bill_date' do
    it 'is same as provided to constructor' do
      expect(subject.bill_date).to eq(bill_date)
    end

    context 'when it is not passed' do
      subject { Wonga::Pantry::Costs.new(nil) }

      it 'is end of current month' do
        bill_date = Time.zone.today.end_of_month
        allow(Date).to receive(:today).and_return(double(end_of_month: bill_date))
        expect(subject.bill_date).to eq(bill_date)
      end
    end

    context 'when it is passed as a string' do
      subject { Wonga::Pantry::Costs.new(bill_date.to_s) }

      it 'is parsed to date' do
        expect(subject.bill_date).to eq(bill_date)
      end
    end
  end
end
