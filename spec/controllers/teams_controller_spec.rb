require 'spec_helper'

describe TeamsController do
  let(:chef_utility) { instance_double('Wonga::Pantry::ChefUtility').as_null_object }
  let(:team) { FactoryGirl.create(:team) }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team_params) { {team: FactoryGirl.attributes_for(:team, name: 'TeamName', description: 'TeamDescription')} }
  let(:user_params) { { users: [username, "Test User"] } }
  let(:username) { 'test.user' }

  describe "POST 'create'" do
    let(:team) { Team.last }

    before :each do 
      Wonga::Pantry::ChefUtility.stub(:new).and_return(chef_utility)
    end

    it "returns http success" do
      post 'create', team_params.merge(users: [user.username, user.name])
      response.should be_redirect
    end

    it "creates a team" do
      expect{ post :create, team_params.merge(users: [user.username, user.name]) }.to change(Team, :count).by(1)
      assigns(:team).name.should == 'TeamName'
      assigns(:team).description.should == 'TeamDescription'
    end
    
    it "creates a team without selecting a user" do
      session[:user_id] = FactoryGirl.create(:user).id
      expect{ post :create, team_params }.to change(Team, :count).by(1)
      expect(team).to have(1).user
    end

    it "creates user and add him to team" do
      expect { post :create, team_params.merge(user_params) }.to change(User, :count).by(1)
      expect(team).to have(1).user
      expect(team.users.first.username).to eq(username)
    end

    it "finds user by its username and adds it to team" do
      user = User.create(username: username)
      expect { post :create, team_params.merge(user_params) }.to_not change(User, :count)
      expect(team).to have(1).users
      expect(team.users.first).to eq(user)
    end

    it "sends SQS message to chef env create daemon" do
      post :create, team_params.merge(users: [user.username, user.name])
      expect(chef_utility).to have_received(:request_chef_environment)
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      # make sure current_user is the stubbed user and is part of team to grant permission
      session[:user_id] = user.id
    end

    it "returns http success" do
      put 'update', team_params.merge({id: team.id})
      response.should be_redirect
    end

    it "should update a team" do 
      put 'update', team_params.merge({id: team.id})
      team.reload.name
      team.name.should == 'TeamName'
    end

    it "finds user by its username and adds it to team" do
      expect{put 'update', team_params.merge({id: team.id}).merge(user_params)}.to change(User, :count)
      expect(team.reload).to have(1).users
      expect(team.users.first.username).to eq(username)
    end

    it "finds user by its username and adds it to team" do
      user = FactoryGirl.create(:user, username: username)
      expect { put :update, team_params.merge({id: team.id}).merge(user_params) }.to_not change(User, :count)
      expect(team.reload).to have(1).user
      expect(team.users.first).to eq(user)
    end

    it "removes users from team if they were not in params" do
      team.users << User.create(username: username)
      put 'update', team_params.merge({id: team.id})
      expect(team).to have(1).users
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      session[:user_id] = user.id
      get 'show', :id => team.id
      response.should be_success
    end
    
    it "sets @can_create_ec2_instance to true" do
      session[:user_id] = user.id
      get 'show', :id => team.id
      assigns(:can_create_ec2_instance).should be_true
    end
  end
end
