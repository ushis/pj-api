class ProfileSerializer < UserSerializer
  attributes :email, :created_at, :updated_at

  root :user
end
