describe "currentUserStore", ->

  $scope    = null
  $http     = null
  succVal   = null
  failVal   = null
  currentUserStore = null

  succ = (it) ->
    succVal = it

  fail = (it) ->
    failVal = it

  testObj = {
    id:   12
    name: "MyName"
  }

  beforeEach ->

    module "Vx"

    inject ['$rootScope',
      (_$scope_) ->
        $scope   = _$scope_.$new()
    ]

    inject ['$injector', ($injector) ->
      $http     = $injector.get("$httpBackend")
      currentUserStore = $injector.get("currentUserStore")
    ]
    succVal = failVal = null

  describe "signOut()", ->

    res =
      location: "/ui"

    beforeEach ->
      $http.expectDELETE('/users/session').respond(res)

    it "should send DELETE request", ->
      $scope.$apply ->
        currentUserStore.signOut().then succ, fail
      $http.flush()
      expect(succVal.data.location).toEqual '/ui'

  describe "get()", ->

    describe "success", ->
      it 'sends GET request', ->
        $http.expectGET('/api/users/me').respond({ role: 'admin' })
        $scope.$apply -> currentUserStore.get()
        $http.flush()

      it 'returns isAdmin = true if role equals "admin"', ->
        $http.expectGET('/api/users/me').respond({ role: 'admin' })

        $scope.$apply ->
          currentUserStore.get().then succ, fail
        $http.flush()

        expect(succVal).toEqual({ role: 'admin', isAdmin: true })

      it 'returns isAdmin = false if role does not equal "admin"', ->
        $http.expectGET('/api/users/me').respond({ role: 'developer' })

        $scope.$apply ->
          currentUserStore.get().then succ, fail
        $http.flush()

        expect(succVal).toEqual({ role: 'developer', isAdmin: false })

      it 'returns existing object on second run', ->
        $http.expectGET('/api/users/me').respond({ role: 'admin' })

        $scope.$apply ->
          currentUserStore.get().then succ, fail
        $http.flush()
        expect(succVal).toEqual({ role: 'admin', isAdmin: true })

        $scope.$apply ->
          currentUserStore.get().then succ, fail
        expect(succVal).toEqual({ role: 'admin', isAdmin: true })

