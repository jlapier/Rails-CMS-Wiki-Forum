Given /there is (\d) existing file/ do |repeat_count|
  repeat_count.to_i.times do
    #FileAttachment.destroy_all
    FileAttachment.create!({
      :uploaded_file => fixture_file_upload("somefile.txt")
    })
  end
  FileAttachment.count.should == repeat_count.to_i 
end