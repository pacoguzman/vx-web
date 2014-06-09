describe 'userStore', ->
  userStore = null
  $scope = null
  $http = null
  successValue = null
  failValue = null

  success = (response) ->
    successValue = response
  fail = (response) ->
    failValue = response

  beforeEach ->
    module('Vx')

    inject ($rootScope) ->
      $scope = $rootScope.$new()

    inject ($injector) ->
      $http = $injector.get('$httpBackend')
      userStore = $injector.get('userStore')

    successValue = failValue = null

  describe 'update()', ->
    it 'sends PATCH request', ->
      user = { id: 1, role: 'developer' }
      $http.expectPATCH("/api/users/#{ user.id }").respond('success')

      $scope.$apply ->
        userStore.update(user)
      $http.flush()

  describe 'all()', ->
    it 'sends GET request', ->
      expected_users = null
      users = [{ id: 1 }]
      $http.expectGET('/api/users').respond(users)

      $scope.$apply ->
        userStore.all().then (response) ->
          expected_users = response
      $http.flush()

      expect(expected_users).toEqual(users)
