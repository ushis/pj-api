class TaggedAddress < Mail::Address

  TAG_SEPARATOR = '+'

  def untagged_local
    local.nil? ? nil : local.split(TAG_SEPARATOR, 2).first
  end

  def tag
    local.nil? ? nil : local.split(TAG_SEPARATOR, 2).second
  end

  def tag=(tag)
    if tag.blank?
      self.local = untagged_local
    else
      self.local = [untagged_local, TAG_SEPARATOR, tag].join
    end
  end

  def local=(local)
    if address.nil?
      self.address = local
    elsif domain.blank?
      self.address = to_s.sub(address, local)
    else
      self.address = to_s.sub(address, "#{local}@#{domain}")
    end
  end
end
