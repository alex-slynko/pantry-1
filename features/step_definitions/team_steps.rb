When(/^An agent creates a new team named "(.*?)"$/) do |name|
  sqs_client = AWS::SQS.new.client
  resp = sqs_client.stub_for(:get_queue_url)
  resp[:queue_url] = "https://sqs.eu.amazonaws.com/1337/fakequeue"  
  click_on 'New Team'
  fill_in('team_name', :with => name)
  fill_in('team_description', :with => "TeamDescription")
  click_button("Submit")
end

Given(/^I update team "(.*?)" with name "(.*?)"$/) do |oldname, newname|
  visit '/teams'
  click_on 'Edit'
  fill_in('team_name', :with => newname)
  click_button("Submit")
end

Given(/^(I am in )?the "(.*?)" team(?: with "(.*?)" user)?$/) do |include_logged_user, team_name, user_name|
  @team = FactoryGirl.create(:team, name: team_name)
  @team.users << User.first if include_logged_user
  user = FactoryGirl.create(:user, name: user_name, team: @team) if user_name
end

Given(/^a LDAP user "(.*?)"$/) do |name|
  LdapResource.stub_chain(:new, :find_user_by_name).and_return([{'samaccountname' => [name], 'email' => [name], 'displayname' => [name]}])
end

When(/^I search for "(.*?)"$/) do |search_term|
  input = find('input[type="search"]')
  input.set(search_term)
end

Then(/^I should see dropdown with "(.*?)"$/) do |text|
  wait_until(5) { page.has_xpath?("//a[contains(text(),'#{text}')]") }
end

When(/^I select "(.*?)" from dropdown$/) do |text|
  page.find(:xpath, "//a[contains(text(),'#{text}')]").click
end

When(/^save team$/) do
  click_on 'Submit'
  page.has_no_button? 'Submit'
end

Then(/^team should (not )?contain "(.*?)"$/) do |not_contains, name|
  user = User.where(name: name).first
  if not_contains
    expect(user.teams).to_not include(Team.last)
  else
    expect(user.teams).to include(Team.last)
  end
end

Given(/^(?:the|a)? "(.*?)" team $/) do |name|
  FactoryGirl.create(:team, name: name)
end

Given(/^the team has a Jenkins server$/) do
  @team.should be_true
  @jenkins_server = FactoryGirl.create(:jenkins_server,
                                       team: @team,
                                       ec2_instance: FactoryGirl.create(:ec2_instance, bootstrapped: true)
  )
end

Then(/^I should see the Jenkins server name$/) do
  page.should have_content @jenkins_server.ec2_instance.name
end

Then(/^I click the server link$/) do
  click_on @jenkins_server.ec2_instance.name
end

Then(/^I should see the url of the Jenkins server$/) do
  page.should have_selector("a[href='http://#{@jenkins_server.ec2_instance.name}.#{@jenkins_server.ec2_instance.domain}']")
end
