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

  beforeEach module("CI")

  beforeEach ->
    inject ['$rootScope',
      (_$scope_) ->
        $scope   = _$scope_.$new()
    ]

  beforeEach ->
    inject ['$injector',
      ($injector) ->
        $http     = $injector.get("$httpBackend")
        currentUserStore = $injector.get("currentUserStore")
    ]
    succVal = failVal = null

  describe "get()", ->

    describe "success", ->
      beforeEach ->
        $http.expectGET('/api/users/me').respond('success')

      it "should send GET request", ->
        $scope.$apply ->
          currentUserStore.get().then succ, fail
        $http.flush()
        expect(succVal).toEqual 'success'

      it "should return existing object on second run", ->
        $scope.$apply ->
          currentUserStore.get().then succ, fail
        $http.flush()
        expect(succVal).toEqual 'success'

        $scope.$apply ->
          currentUserStore.get().then succ, fail
        expect(succVal).toEqual 'success'

