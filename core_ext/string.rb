class String
  def lastline
    if pos = rindex(?\n)
      self[(pos+1)..-1]
    else
      self
    end
  end
end

