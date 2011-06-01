def spec_associations(associations, options={})
  subject = options[:class] unless subject.present?
  if subject.blank?
    raise ArgumentError, "spec_associations expects a subject to be set to the target class; eg subject{ YourActiveRecordModel }"
  end
  it_prefix = options[:it_prefix]
  it_prefix += " " unless it_prefix.blank?
  associations.each do |type, names|
    names.each do |name|
      it "#{it_prefix}#{type} #{name}" do
        subject.to_s.constantize.reflections.should include(name.to_sym)
      end
    end
  end  
end
