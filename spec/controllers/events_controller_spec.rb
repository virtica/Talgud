require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController do
  
  describe 'index' do
    it 'should show a list of events' do
      events = Array.new(10) { |i| Factory.create(:event) }
      
      get :index
      assigns[:events].each { |e| events.should include(e) }
    end
    
    it 'should be accessible by all users' do
      get :index
      response.should be_success
    end
    
    it 'should filter events if requested' do
      e1 = Factory.create(:event, :location_address_county => Factory.create(:county), :event_type => Factory.create(:event_type))
      e2 = Factory.create(:event, :location_address_county => Factory.create(:county), :event_type => e1.event_type)
      e3 = Factory.create(:event, :location_address_county => e2.location_address_county, :event_type => Factory.create(:event_type))
      
      get :index, {:county => e2.location_address_county.id, :event_type => e2.event_type.id}
      assigns[:events].should include(e2)
      assigns[:events].should_not include(e1, e3)
      
      get :index, {:county => e2.location_address_county.id}
      assigns[:events].should include(e2, e3)
      assigns[:events].should_not include(e1)
      
      get :index, {:event_type => e1.event_type.id}
      assigns[:events].should include(e1, e2)
      assigns[:events].should_not include(e3)
    end
  end

  describe 'new' do
    it 'should not be displayed when user is not logged in' do
      get :new
      response.should redirect_to(root_path)
    end
    
    it 'should be displayed when user is logged in' do
      activate_authlogic and UserSession.create(Factory.create(:user))
        
      get :new
      response.should be_success
    end
  end
  
  describe 'create' do
    before(:each) do
      @user = Factory.create(:user)
      @event = Factory.build(:event)
    end
    
    context 'with authenticated users' do
      before(:each) do
        activate_authlogic and UserSession.create(@user)
      end
      
      it 'should create event and assign current user as manager when event is valid' do
        post :create, {:event => @event.attributes.merge('language_ids' => [Factory(:language).id])}
        response.should redirect_to(event_path(assigns[:event]))
        assigns[:event].manager.should eql(@user)
      end
      
      it 'should send e-mail notification to region manager' do
        county = Factory(:county)
        regional_manager = Factory(:user)
        Role.grant_role(Role::ROLE[:regional_manager], regional_manager, county)
        
        @event.location_address_county = county
        Mailers::EventMailer.should_receive(:deliver_region_manager_notification)
        
        post :create, {:event => @event.attributes.merge('language_ids' => [Factory(:language).id])}
      end
      
      it 'should redisplay event create form when event data is invalid' do
        post :create, {:event => @event.attributes.merge('name' => '')}
        response.should render_template(:new)
      end
    end
    
    it 'should not be accessible to guests' do
      post :create, {:event => @event.attributes}
      response.should redirect_to(root_path)
    end
  end
  
  describe 'show' do
    it 'should load event by event URL' do
      [Event::STATUS[:published], Event::STATUS[:registration_open], Event::STATUS[:registration_closed]].each do |status|
        event = Factory(:event, :status => status)
        get :show, {:id => event.url}
        response.should be_success
        assigns[:event].should eql(event)
      end
    end
    
    it 'should not show unpublished event to public users' do
      event = Factory(:event, :status => Event::STATUS[:new])
      get :show, {:id => event.url}
      response.should redirect_to(root_path)
    end
    
    it 'should show unpublished event to event manager' do
      user = Factory.create(:user)
      activate_authlogic and UserSession.create(user)
      
      event = Factory(:event, :status => Event::STATUS[:new], :manager => user)
      
      get :show, {:id => event.url}
      response.should be_success
      assigns[:event].should eql(event)
    end
  end
  
  describe 'edit' do
    it 'should be accessible for users in event manager role' do
      user = Factory.create(:user)
      activate_authlogic and UserSession.create(user)

      another_user = Factory.create(:user)
      
      event = Factory(:event, :status => Event::STATUS[:new], :manager => another_user)
      get :edit, {:id => event.url}
      response.should redirect_to(root_path)
      
      Role.grant_role(Role::ROLE[:event_manager], user, event)
      get :edit, {:id => event.url}
      response.should be_success
      assigns[:event].should eql(event)
    end
  end
  
  describe 'update' do
    before(:each) do
      @user = Factory.create(:user)
      activate_authlogic and UserSession.create(@user)
    end
    
    it 'should be accessible for users in event manager role' do
      another_user = Factory.create(:user)
      
      event = Factory(:event, :status => Event::STATUS[:new], :manager => another_user)
      post :update, {:id => event.url, :event => event.attributes}
      response.should redirect_to(root_path)
      
      Role.grant_role(Role::ROLE[:event_manager], @user, event)
      
      post :update, {:id => event.url, :event => event.attributes}
      response.should redirect_to(event_path(event))
    end
    
    it 'should update event with valid attributes' do
      event = Factory(:event, :manager => @user)
      post :update, {:id => event.url, :event => event.attributes}
      response.should redirect_to(event_path(event))
    end
    
    it 'should not update event with invalid attributes and render edit view again' do
      event = Factory(:event, :manager => @user)
      post :update, {:id => event.url, :event => event.attributes.merge('name' => '')}
      response.should render_template(:new)
    end
  end
  
  describe 'map' do
    it 'should be accessible to all users' do
      get :map
      response.should be_success
    end
  end
end
