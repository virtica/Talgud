require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event, 'validations' do
  it 'should validate that begin date is before end date' do
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 0.days.ago).should be_valid
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 2.days.ago).should be_invalid
    Factory.build(:event, :begins_at => 1.day.ago, :ends_at => 1.days.ago).should be_valid
  end
  
  it 'should validate that begin time is before end time' do
    time = 1.day.from_now
    Factory.build(:event, :begins_at => time, :ends_at => time).should be_valid
    # TODO: mutating start and end time should be possible by simply declaring them as create attributes
    f = Factory.build(:event, :begins_at => time, :ends_at => time)
    f.begin_time = '11:00'
    f.end_time = '10:00'
    f.should be_invalid
  end

  it 'should validate that number of participants is a positive number' do
    Factory(:event, :max_participants => 1).should be_valid
    Factory.build(:event, :max_participants => 0).should be_invalid
    Factory.build(:event, :max_participants => -1).should be_invalid
  end
end

describe Event, 'create' do
  it 'should associate event manager role to creator of the event' do
    @event = Factory(:event)
    @event.roles.should_not be_nil
    @event.roles.collect(&:role).should include(Role::ROLE[:event_manager])
  end
end

describe Event, 'start and end time' do
  it 'should return formatted time' do
    @event = Factory.build(:event)
    @event.begin_time = '9:09'
    @event.begin_time.should eql('9:09')
    @event.end_time = '21:12'
    @event.end_time.should eql('21:12')
  end
end

describe Event, 'start and end time changing' do
  it 'should update time but keep date intact' do
    @event = Factory.build(:event)
    @event.begin_time = '9:09'
    @event.begins_at.hour.should eql(9)
    @event.begins_at.min.should eql(9)
    
    @event.end_time = '21:12'
    @event.ends_at.hour.should eql(21)
    @event.ends_at.min.should eql(12)
  end
end

describe Event, 'vacancies' do
  it 'should calculate vacancies' do
    @event = Factory.build(:event, :max_participants => 10, :current_participants => 2)
    @event.vacancies.should eql(8)
  end

  it 'should return 0 vacancies' do
    @event = Factory.build(:event, :max_participants => 10, :current_participants => 11)
    @event.vacancies.should eql(0)
  end
end

describe Event, 'event code generation' do
  it 'should generate event code' do
    @event = Factory(:event)
    @event.code.should_not be_nil
  end

  it 'should validate dublicate event code' do
    @event = Factory(:event)
    @event.code.should_not be_nil        
    
    @event2 = Factory.build(:event, :code => @event.code)
    @event2.stub!(:code).and_return @event.code    
    
    @event2.should be_invalid
    @event2.should have(1).error_on(:code)
  end

  it 'should not miss event code sequence on invalid event' do
    @event = Factory.build(:event, :name => nil)
    @event.should be_invalid
    @event.code.length.should eql(24)
    @event.name = '1234'
    @event.should be_valid
    @event.save!    
    @event.code.length.should eql(7)
  end

  it 'should not generate new event code on save' do
    @event = Factory(:event)
    code = @event.code
    @event.name = '1234'
    @event.save!
    @event.code.should eql(code)
  end
end

describe Event, 'regional_managers' do
  before(:each) do
    @regional_manager = Factory(:user)

    @county = Factory(:county)
    @municipality = Factory(:municipality)
    @settlement = Factory(:settlement)
    @event = Factory(:event, :location_address_settlement => @settlement, :location_address_municipality => @municipality, :location_address_county => @county)
  end

  it 'should give list of users associated with event location settlement if available' do
    Role.grant_role(Role::ROLE[:regional_manager], @regional_manager, @settlement)
    @event.regional_managers.should include(@regional_manager)
  end

  it 'should give list of users associated with event location municipality if available' do
    Role.grant_role(Role::ROLE[:regional_manager], @regional_manager, @municipality)
    @event.regional_managers.should include(@regional_manager)
  end

  it 'should give list of users associated with event location county if available' do
    Role.grant_role(Role::ROLE[:regional_manager], @regional_manager, @county)
    @event.regional_managers.should include(@regional_manager)
  end
end
