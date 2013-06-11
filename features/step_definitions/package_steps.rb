Given(/^a build agent has provided a package of name "(.*?)" with version "(.*?)" placed on url "(.*?)"$/) do |name, version, url|
  page.driver.post "/packages", {name: name, version: version, url: url, bag_title: 'DataBag', item_title: 'Item'}
end

When(/^I am on packages page$/) do
  visit '/packages'
end
