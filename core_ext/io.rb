class IO
  def tmp_reopen(io)
    save = self.dup
    begin
      self.reopen(io)
      begin
        yield
      ensure
        self.reopen(save)
      end
    ensure
      save.close
    end
  end
end


