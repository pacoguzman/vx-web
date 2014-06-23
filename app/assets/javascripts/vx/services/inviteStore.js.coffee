Vx.service 'inviteStore', ($http, $q) ->
  create = (emails) ->
    $http.post('/api/invites', invite: { emails: emails })

  create: create
