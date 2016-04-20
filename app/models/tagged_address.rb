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

  # Works around a bug in mail. See fix in the next release:
  #
  # https://github.com/mikel/mail/commit/8cb227828e53f7b078c68573fc4214796a6d11b9
  def display_name
    super
  rescue NoMethodError
    nil
  end

  # Works around a bug in mail. See fix in the next release:
  #
  # https://github.com/mikel/mail/commit/8cb227828e53f7b078c68573fc4214796a6d11b9
  def display_name=(name)
    super(name.to_s)
  end
end
