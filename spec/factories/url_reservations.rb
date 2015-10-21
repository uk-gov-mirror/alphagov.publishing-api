# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :url_reservation do
    sequence(:base_path) {|n| "/path#{n}" }
    publishing_app  "publisher"
  end
end
