class String
  # replace parts of a string based on a hash
  # ex:
  # replace_hash = { "car" => "bike", "potato chips" => "apples", "store" => "fruit stand" }
  # my_string = "I'm going to take my car to the store and buy potato chips."
  # my_string.gsub_from_hash(replace_hash)
  # => "I'm going to take my bike to the fruit stand and buy apples."
  def gsub_from_hash(somehash = {})
    temp = self
    for part in somehash
      unless part[0].nil? or part[1].nil?
        temp = temp.gsub(part[0], part[1])
      end
    end
    temp
  end

  def unspace()
    self.gsub(" ", "_")
  end

  def respace()
    self.gsub("_", " ")
  end
end