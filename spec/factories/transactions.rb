FactoryGirl.define do
  factory :transaction do
    public_id { UUID.generate }
  end
end
