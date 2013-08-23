require 'spec_helper'

describe JenkinsSlavesController do
  let(:jenkins_server) {FactoryGirl.create(:jenkins_server, team: team)}
  let(:jenkins_slave) {FactoryGirl.create(:jenkins_slave, jenkins_server: jenkins_server)}
  let(:user) {FactoryGirl.create(:user, team: team)}
  let(:team) {FactoryGirl.create(:team)}

  before(:each) do
  	session[:user_id] = user.id
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, jenkins_server_id: jenkins_server.id
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
    end
  end
  
  describe "GET 'show'" do
    it "returns http success" do
      get :show, jenkins_server_id: jenkins_server.id, id: jenkins_slave.id
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
      assigns(:ec2_instance).id.should be jenkins_slave.ec2_instance.id
    end
  end
  
  describe "GET 'new'" do
    it "returns http success" do
      get :new, jenkins_server_id: jenkins_server.id
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
      assigns(:jenkins_slave).should_not be_nil
    end
  end
  
  describe "POST 'create'" do
    before(:each) do
      client = AWS::SQS.new.client
      resp = client.stub_for(:get_queue_url)
      resp[:queue_url] = "https://sqs.eu-west-1.amazonaws.com/000000000000/blop"
      sqs_sender = Wonga::Pantry::SQSSender.new()
      @aws_utility = Wonga::Pantry::AWSUtility.new(sqs_sender)
    end
    
    it "redirects on success" do
      post :create, jenkins_server_id: jenkins_server.id
      response.should be_redirect
    end
    
    it "renders new if JenkinsSlave was not saved" do
      JenkinsSlave.any_instance.stub(:persisted?).and_return(false)
      
      post :create, jenkins_server_id: jenkins_server.id
      response.should render_template('new')
    end
    
    it "assigns the teams to the current user if JenkinsSlave was not saved" do
      JenkinsSlave.any_instance.stub(:persisted?).and_return(false)
      
      post :create, jenkins_server_id: jenkins_server.id
      assigns(:user_teams).size.should be 
    end
    
    it "creates new slave with the master ID" do      
      post :create, jenkins_server_id: jenkins_server.id
      assigns(:jenkins_slave).jenkins_server_id.should be jenkins_server.id
  	end
  end

end
