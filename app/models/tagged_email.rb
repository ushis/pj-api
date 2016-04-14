class TaggedEmail < Mail::Address

  def untagged_local
    local.split('+', 2).first
  end

  def tag
    local.split('+', 2).second
  end

  def tag=(tag)
    if tag.blank?
      self.local = untagged_local
    else
      self.local = "#{untagged_local}+#{tag}"
    end
  end

  def local=(local)
    if domain.blank?
      self.address = to_s.sub(address, local)
    else
      self.address = to_s.sub(address, "#{local}@#{domain}")
    end
  end
end
