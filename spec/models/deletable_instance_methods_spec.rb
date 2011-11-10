require 'spec_helper'
require 'acts_as_fu'
RSpec.configure do |config|
  config.include ActsAsFu
end

describe DeletableInstanceMethods do
  before(:each) do
    build_model :fake_revisable do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env.to_sym])
      string :first_name
      string :last_name
      datetime :revisable_deleted_at
      boolean :revisable_is_current
      integer :revisable_original_id
      integer :revisable_number
      datetime :created_at
      datetime :revisable_current_at
      datetime :revisable_revised_at
      
      acts_as_revisable :revision_class_name => 'FakeRevision', :on_delete => :revise
    end
    build_model :fake_revision do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[Rails.env.to_sym])
      string :first_name
      string :last_name
      datetime :revisable_deleted_at
      boolean :revisable_is_current
      integer :revisable_original_id
      integer :revisable_number
      datetime :created_at
      datetime :revisable_current_at
      datetime :revisable_revised_at
      
      acts_as_revision :revisable_class_name => 'FakeRevisable'
      
      include DeletableInstanceMethods
    end
    
    @fake_revisable = FakeRevisable.create!({
      :first_name => 'Some',
      :last_name => 'Name'
    })
    @fake_revisable.destroy
    @fake_revision = FakeRevision.find(@fake_revisable.id)
  end
  describe "restoring a deleted revision" do
    it "sets revisable_deleted_at to nil" do
      @fake_revision.should_receive(:revisable_deleted_at=).with(nil)
      @fake_revision.restore
    end
    it "sets revisable_is_current to true" do
      @fake_revision.should_receive(:revisable_is_current=).with(true)
      @fake_revision.restore
    end
    it "saves the updated revision" do
      @fake_revision.should_receive(:save)
      @fake_revision.restore
    end
  end
end
