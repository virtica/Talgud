Factory.define :account do |a|
  a.name 'Account'
  a.domain 'test.local'
end

Factory.define :county do |c|
  c.sequence(:name) { |n| "County #{n}" }
end

Factory.define :municipality do |m|
  m.sequence(:name) { |n| "Municipality #{n}" }
  m.kind Municipality::KIND.first
  m.association :county
end

Factory.define :settlement do |s|
  s.sequence(:name) { |n| "Settlement #{n}" }
  s.kind Settlement::KIND.first
  s.association :municipality
end

Factory.define :event_type do |et|
  et.sequence(:name) { |n| "Event type #{n}" }
end

Factory.define :event do |e|
  e.sequence(:name) { |n| "Event #{n}" }
  e.begins_at 1.day.from_now
  e.ends_at 2.days.from_now
  e.location_address_country_code 'ee'
  e.status Event::STATUS[:published]
  
  e.association :event_type
  e.association :location_address_county, :factory => :county
  e.association :location_address_municipality, :factory => :municipality
  e.association :manager, :factory => :user
end

Factory.define :role do |r|
  
end

Factory.define :user do |u|
  u.firstname 'Admin'
  u.lastname 'User'
  u.sequence(:email) { |n| "admin#{n}@example.com" }
  u.password 'admin'
  u.password_confirmation 'admin'
  u.status User::STATUS[:active]
end

Factory.define :user_not_activated, :parent => :user do |u|
  u.perishable_token 'perishable_token'
  u.status User::STATUS[:created]
end