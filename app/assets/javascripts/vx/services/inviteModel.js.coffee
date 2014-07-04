Vx.service 'inviteModel', ['$http',
  ($http) ->
    create: (emails) ->
      $http.post('/api/invites', invite: { emails: emails })
]
