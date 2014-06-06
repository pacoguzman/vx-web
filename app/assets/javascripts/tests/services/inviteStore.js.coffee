describe 'inviteStore', ->
  inviteStore = null
  $scope = null
  $http  = null

  beforeEach ->
    module('Vx')
    inject ($rootScope) ->
      $scope = $rootScope.$new()
    inject ($injector) ->
      $http = $injector.get('$httpBackend')
      inviteStore = $injector.get('inviteStore')

  describe 'create()', ->
    it 'sends POST request', ->
      invite = { emails: 'invited@example.com invited1@example.com' }
      response = null
      $http.expectPOST('/api/invites').respond('success')

      $scope.$apply ->
        inviteStore.create(invite.emails).then (re) ->
          response = re.data
      $http.flush()

      expect(response).toEqual('success')
