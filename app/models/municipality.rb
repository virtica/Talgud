class Municipality < ActiveRecord::Base
  
  acts_as_scoped :account
  
  KIND = [:linn, :vald]
  
  belongs_to :county
  has_many :settlements
  has_many :roles, :as => :model
  has_many :manager_roles, :as => :model, :class_name => 'Role', :conditions => {:role => Role::ROLE[:regional_manager]}
  has_many :managers, :through => :manager_roles, :source => :user
  
  validates_presence_of :name, :kind, :county
  
  default_scope :conditions => {:deleted_at => nil}
  named_scope :sorted, :order => {:name => ' ASC'}

  def self.class_role_symbols
    [:regional_manager]
  end
  
  def label
    [county.label, self.name].join(' / ')
  end
  
end
