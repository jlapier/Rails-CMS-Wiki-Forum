Spec::Matchers.define :equal_without_whitespace do |expected|
  match do |actual|
    actual.gsub(/\s/, '') == expected.gsub(/\s/, '')
  end
end
