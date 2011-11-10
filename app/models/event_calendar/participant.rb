module Participant
  @@types ||= []
  
  def self.included(base)
    return if @@types.include?(base)
    
    @@types << base
    
    base.instance_eval do
      include Associations
    end
  end
  def self.types
    @@types.sort
  end
  
  module Associations
    def self.included(base)
      base.instance_eval do
        has_many :attendees, {:as => :participant, :dependent => :destroy}
        has_many :events, {:through => :attendees}
      end
    end
  end
end