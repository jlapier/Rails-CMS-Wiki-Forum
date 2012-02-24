require 'spec_helper'

describe FileAttachmentsController do  
  def flash_now 
    controller.instance_eval{flash.stub!(:sweep)} 
  end
  
  def mock_container
    @mock_container ||= mock_model(FileAttachment)
  end

  def mock_file_attachment
    @mock_file_attachment ||= mock_model(FileAttachment, {
      :uploaded_file => some_file,
      :filepath= => nil,
      :name => 'what',
      :attachable_id => mock_container.id,
      :attachable_type => mock_container.class,
      :attachable => mock_container,
      :save => true
    })
  end

  def some_file
    #fixture_file_upload(File.join(Rails.root.to_s, 'spec', 'fixtures', 'somefile.txt'), 'text/plain')
    fixture_file_upload('/somefile.txt', 'text/plain')
  end

  describe "when logged in as admin" do
    before do
      FileAttachment.stub(:new).and_return(mock_file_attachment)
      @params = {
        :description => "blah blah",
        :name => "agenda",
        :uploaded_file => some_file,
        :container => "MockContainer_#{mock_container.id}"
      }
      controller.stub!(:current_user).and_return(mock_user)
    end
    
    context "http upload" do
      context "no file is selected for upload" do
        it "redirects to the home page if no file was uploaded" do
          post :create, :file_attachment => {}
          response.should redirect_to(file_attachments_path(:std => 1))
        end
        it "sets a flash[:warning]" do
          post :create, :file_attachment => {}
          flash[:warning].should_not be_nil
        end
      end
      it "should upload a new file attachment with an attachable" do
        FileAttachment.should_receive(:new).and_return(mock_file_attachment)
        post :create, :file_attachment => @params
        response.should redirect_to(file_attachment_path(mock_container, {:std => 1}))
      end
      it "should upload a new file attachment without an attachable" do
        @params.merge!(:container => '')
        mock_file = mock_model(FileAttachment, @params.merge({
          :save => nil,
          :errors => mock('Error', {
            :full_messages => []
          }),
          :attachable_id => '',
          :attachable_type => '',
          :attachable => nil
        }))
        FileAttachment.should_receive(:new).and_return(mock_file)
        post :create, :file_attachment => @params
      end
      it "should save the new file attachment" do
        mock_file_attachment.should_receive(:save)
        post :create, :file_attachment => @params
      end
      it "when file is attached to an attachable, redirect to the attachable page" do
        post :create, :file_attachment => @params
        response.should redirect_to file_attachment_path(mock_container, :std => 1)
      end
      it "when file is not attached, redirect to the file attachments page" do
        mock_file = mock_model(FileAttachment, {
          :uploaded_file => some_file,
          :filepath => nil,
          :name => 'what',
          :save => true,
          :attachable_id => '',
          :attachable_type => '',
          :attachable => nil
        })
        FileAttachment.stub(:new).and_return(mock_file)
        post :create, :file_attachment => @params
        response.should redirect_to file_attachments_path(:std => 1)
      end
    end
    
    context "plupload" do
      
      before(:each) do
        @params.delete(:name) && @params.delete(:description)
      end
      
      it "should upload a new file attachment with an attachable" do
        FileAttachment.should_receive(:new).and_return(mock_file_attachment)
        
        post :create, {
          :file => some_file,
          :attachable_type => 'MockContainer',
          :attachable_id => mock_container.id
        }
        
        assigns[:file_attachment].should == mock_file_attachment
        
        response.should render_template('file_attachments/_file_attachment')
      end
      
      it "should upload a new file attachment without an event" do
        post :create, {
          :file => some_file
        }
        
        assigns[:file_attachment].should == mock_file_attachment
      end
    end
    
    context "delete a file" do
      
      before(:each) do
        FileAttachment.stub(:find).and_return(mock_file_attachment)
        mock_file_attachment.stub(:full_path).and_return(File.join(Rails.root.to_s, 'spec', 'fixtures', 'somefile.txt'))
        mock_file_attachment.stub(:destroy).and_return(mock_file_attachment)
        File.stub(:rm)
      end
      
      it "load the file attachment" do
        FileAttachment.should_receive(:find).and_return(mock_file_attachment)
        post :destroy, :id => 1
        assigns[:file_attachment].should == mock_file_attachment
      end
      
      it "destroys the file attachment" do
        mock_file_attachment.should_receive(:destroy)
        post :destroy, :id => 1
      end
      
      it "sets a flash[:notice]" do
        post :destroy, :id => 1
        flash[:notice].should_not be_nil
      end
      
    end

  end
  
  describe "when Errno::ENOENT is raised" do
    
    before(:each) do
      controller.stub!(:current_user).and_return(mock_user)
      FileAttachment.stub(:find).and_return(mock_file_attachment)
      mock_file_attachment.stub(:destroy).and_raise(Errno::ENOENT.new("File not found"))
    end
    
    it "logs the error" do
      controller.logger.should_receive(:error).with("FileAttachmentsController[destroy] was rescued with :file_not_found. No such file or directory - File not found")
      post :destroy, :id => 1
    end
    
    it "sets a flash[:warning]" do
      post :destroy, :id => 1
      flash[:warning].should =~ /The physical file/  #_not be_nil
    end
    
  end
  
  describe ":show, :id => int" do
    before(:each) do
      FileAttachment.stub(:find).and_return(mock_file_attachment)
    end
    it "loads a @file_attachment" do
      FileAttachment.should_receive(:find).with('1').and_return(mock_file_attachment)
      get :show, :id => "1"
      assigns[:file_attachment].should eql mock_file_attachment
    end
    it "renders the show template" do
      get :show, :id => "1"
      response.should render_template("file_attachments/show")
    end
  end
  
  describe ":edit, :id => integer" do
    
    before(:each) do
      FileAttachment.stub(:find).and_return(mock_file_attachment)
      controller.stub!(:current_user).and_return(mock_user)
    end
    
    it "loads a file_attachment as @file_attachment" do
      FileAttachment.should_receive(:find).with('1').and_return(mock_file_attachment)
      get :edit, :id => "1"
      assigns[:file_attachment].should eql @mock_file_attachment
    end
    
  end
  
  describe ":update, :id => integer, :file_attachment => {}" do
    
    before(:each) do
      controller.stub!(:current_user).and_return(mock_user)
      FileAttachment.stub(:find).and_return(mock_file_attachment)
      mock_file_attachment.stub(:update_attributes).and_return(nil)
    end
    
    it "loads a file attachment" do
      FileAttachment.should_receive(:find).with('1').and_return(@mock_file_attachment)
      put :update, :id => "1"
      assigns[:file_attachment].should == @mock_file_attachment
    end
  
    it "updates the file attachment" do
      @mock_file_attachment.should_receive(:update_attributes).with({
        'description' => 'some lovely new description',
        'name' => 'slightly.modified.txt'
      }).and_return(nil)
      put :update, :id => 1, :file_attachment => {
        :description => 'some lovely new description',
        :name => 'slightly.modified.txt'
      }
    end
  
    context "update succeeds (std HTML POST:)" do
    
      before(:each) do
        @mock_file_attachment.stub(:update_attributes).and_return(true)
      end
    
      it "sets a flash[:notice]" do
        put :update, :id => "1"
        flash[:notice].should_not be_nil
      end
    
      it "redirects to index or event for file" do
        put :update, :id => "1"
        response.should redirect_to(file_attachment_path(mock_container))
      end
    
    end
  
    context "update fails (std HTML POST):" do
    
      before(:each) do
        flash_now
        @mock_file_attachment.stub(:update_attributes).and_return(false)
      end
    
      it "sets a flash[:warning]" do
        put :update, :id => "1"
        flash[:warning].should_not be_nil
      end
    
      it "renders the edit template" do
        put :update, :id => "1"
        response.should render_template('file_attachments/edit')
      end
      
    end
    
    context "xhr POST" do
      it "renders the update template" do
        xhr :put, :update, :id => "1"
        response.should render_template("file_attachments/update")
      end
    end
    
  end
  
  describe ":download, :id => required" do
    before(:each) do
      mock_file_attachment.stub(:full_path).and_return(File.join(Rails.root.to_s, 'spec', 'fixtures', 'somefile.txt'))
      FileAttachment.stub(:find).and_return(mock_file_attachment)
    end
    it ":download, :id => required" do
      controller.stub(:render)
      controller.should_receive(:send_data).with(
        File.new(File.join(Rails.root.to_s, 'spec', 'fixtures', 'somefile.txt')).read,
        :filename => 'somefile.txt',
        :stream => true,
        :buffer_size => 1.megabyte
      )
      get :download, :id => mock_file_attachment.id
    end
  end
  
  describe ":index" do
    before(:each) do
      FileAttachment.stub(:all).and_return([mock_file_attachment])
      mock_container.class.stub(:all).and_return([mock_container])
    end
    it "loads orphaned file attachments as @orphans" do
      FileAttachment.should_receive(:orphans).and_return([mock_file_attachment])
      get :index
      assigns[:orphans].should eql [mock_file_attachment]
    end
    it "loads attached file attachments as @files" do
      FileAttachment.should_receive(:attached).and_return([mock_file_attachment])
      get :index
      assigns[:files].should eql [mock_file_attachment]
    end
    it "renders the index template" do
      get :index
      response.should render_template("file_attachments/index")
    end
  end

end
