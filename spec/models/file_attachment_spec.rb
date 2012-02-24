require 'spec_helper'

describe FileAttachment do

  include ActionDispatch::TestProcess # for fixture_file_upload

  module Blog; class Post; extend ActiveModel::Naming; def self.base_class; Blog::Post; end end end
  class Event; extend ActiveModel::Naming; def self.base_class; Event; end end
  
  before(:each) do
#    File.stub(:open)
    @path = File.join(Rails.root.to_s, 'public', 'files', 'general')
    @full_path = File.join(@path, 'somefile.txt')
    @trash_path = File.join(@path, 'trash', 'somefile.txt')
    @somefile = fixture_file_upload('/somefile.txt', 'text/plain')

    @file_attachment = FileAttachment.new({
      :description => 'unique description',
      :uploaded_file => @somefile
    })
    @file_attachment.valid? # force build_filepath
  end

  after(:each) do
    FileUtils.rm_f(@full_path)
  end

  context "generating a unique filename" do
    before(:each) do
      @new_file = FileAttachment.new({
        :description => 'other description',
        :uploaded_file => @somefile 
      })
    end
    it "should generate a unique name on create" do
      File.stub(:open)
      File.stub(:exists?).with("#{@path}/somefile.txt"){ true }
      File.stub(:exists?).with("#{@path}/somefile-1.txt"){ false }
      File.should_receive(:open).with("#{@path}/somefile-1.txt", "wb").at_least(:once)
      @new_file.save
    end
    it "should not generate a unique name on update" do 
      @new_file.save
      @new_file.should_not_receive(:generate_unique_filename)
      @new_file.save
    end
  end
  
  it "should know whether its file actually exists" do
    File.stub(:exists?).with("#{@path}/somefile.txt"){ true }
    @file_attachment.file_saved?.should be_true
    File.stub(:exists?).with("#{@path}/somefile.txt"){ false }
    @file_attachment.file_saved?.should be_false
  end
  
  it "should move its file to the trash when destroyed" do
    @file_attachment.should_receive(:move_file_to_trash_folder!)
    @file_attachment.destroy
  end
  
  it "should know how to throw files into the trash" do
    @file_attachment.stub(:generate_unique_filename){ "somefile.txt" }
    File.stub(:exists?){ true }
    FileUtils.should_receive(:mv).with(@full_path, @trash_path)
    @file_attachment.send(:move_file_to_trash_folder!)
  end
  
  context "determine storage path" do
    it "uses public/files/general without an attachable" do
      @file_attachment.send(:attachable_folder).should eq "general"
      @file_attachment.filepath.should eq "public/files/general/somefile.txt"
    end
    it "uses public/files/blog/post/:post_id with an attachable of class Blog::Post" do
      blog_post = mock_model(Blog::Post)
      @file_attachment.attachable = blog_post
      @file_attachment.valid?
      @file_attachment.send(:attachable_folder).should eq "blog/post/#{blog_post.id}"
      @file_attachment.filepath.should eq "public/files/blog/post/#{blog_post.id}/somefile.txt"
    end
    it "uses public/files/event/:event_id with an attachable of class Event" do
      event = mock_model(Event)
      @file_attachment.attachable = event
      @file_attachment.valid?
      @file_attachment.send(:attachable_folder).should eq "event/#{event.id}"
      @file_attachment.filepath.should eq "public/files/event/#{event.id}/somefile.txt"
    end
  end
  
  it "should ensure that the destination folder exists" do
    FileUtils.should_receive(:mkdir_p).with(@path)
    @file_attachment.send(:ensure_folder_path_exists)
  end
  
  context "should be able to update filepath in db & fs" do
    before(:each) do
      @old_path = File.join "public", "files", "somefile.txt"
      @file_attachment.filepath = @old_path
      FileUtils.stub(:mv).with("#{Rails.root}/#{@old_path}", @full_path)
    end
    it "update the fs" do
      FileUtils.should_receive(:mv).with("#{Rails.root}/#{@old_path}", @full_path)
      @file_attachment.update_filepath
    end
    context "fs update succeeds :)" do
      it "update the db" do
        @file_attachment.stub(:file_saved?){ true }
        @file_attachment.should_receive(:save)
        @file_attachment.update_filepath
      end
    end
    context "fs update fails :(" do
      before(:each) do
        @file_attachment.stub(:file_saved?){ false }
      end
      it "add error to base" do
        @file_attachment.errors.should_receive(:add).with(:base, "Error updating filepath for #{@file_attachment.name}")
        @file_attachment.update_filepath
      end
      it "return false" do
        @file_attachment.update_filepath.should be_false
      end
    end
  end
end
