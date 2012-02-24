module FileContainer
  mattr_reader :types
  
  @@types ||= []

  def self.included(base)
    return if @@types.include?(base)
    
    @@types << base
  
    base.instance_eval do
      include Associations
    end
  end

  def self.all
    @all ||= types.map{|t| t.where(1)} # lazy load :all of each type
  end

  module Associations
    def self.included(base)
      base.instance_eval do
        has_many :file_attachments, {
          :as => :attachable,
          :dependent => :destroy
        }
      end
    end
  end
end