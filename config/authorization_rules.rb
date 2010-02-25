authorization do
  role :account_manager do
    has_permission_on [:admin_counties, :admin_event_types, :admin_municipalities, :admin_settelments, :admin_users, :admin_languages], :to => [:manage]
    has_permission_on [:admin_events], :to => [:manage, :map]
  end

  role :regional_manager do
    has_permission_on [:admin_events], :to => [:manage, :map]
  end

  role :event_manager do
    has_permission_on [:events], :to => [:manage]
    has_permission_on [:event_participant], :to => [:manage]
  end

  role :event_participant do
    has_permission_on [:event_participants], :to => [:manage]
  end

  role :guest do
    has_permission_on [:home], :to => [:see]
    has_permission_on [:user_sessions], :to => [:manage]
    has_permission_on [:events], :to => [:see, :map]
  end

  role :user do
    includes :guest
    has_permission_on [:events], :to => [:new, :create]
  end
end

privileges do
  privilege :manage do
    includes :show, :new, :create, :edit, :update, :destroy, :see
  end

  privilege :see do
    includes :index, :show
  end
end
