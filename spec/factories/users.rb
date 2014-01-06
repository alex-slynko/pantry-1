# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    ignore do
      team nil
    end
    username "MyString"
    role 'developer'

    callback(:after_build, :after_stub) do |user, evaluator|
      user.teams << evaluator.team if evaluator.team
    end
  end
end
