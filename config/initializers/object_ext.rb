class Object
  def to_english
    self.class.to_s.demodulize.humanize.downcase
  end
end
