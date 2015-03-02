class SessionSerializer < ProfileSerializer
  attributes :access_token

  root :user
end
