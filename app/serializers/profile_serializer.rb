class ProfileSerializer < UserSerializer
  attributes :email, :time_zone, :created_at, :updated_at

  root :user

  def time_zone
    object.time_zone.tzinfo.name
  end
end
