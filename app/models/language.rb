class Language < ActiveRecord::Base  
  
  acts_as_scoped :account

  has_and_belongs_to_many :events
  
  validates_presence_of :name, :code
  validates_uniqueness_of :code, :case_sensitive => false  
  
  default_scope :conditions => {:deleted_at => nil}
  named_scope :sorted, :order => {:name => ' ASC'}
  
  def name
    I18n.translate("formtastic.labels.language.languages.#{self.attributes['code'].downcase}", :default => self.attributes['name'])
  end  
end
