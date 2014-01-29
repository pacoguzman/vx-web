describe "userRepoStore", ->

  $scope   = null
  repos    = null
  $http    = null
  expected = null

  testObj = {
    id:   12
    name: "MyName"
    subscribed: false
  }

  testObj2 = {
    id:   14
    name: "MyName"
    subscribed: false
  }

  beforeEach module("Vx")

  beforeEach ->
    inject ['$rootScope',
      (_$scope_) ->
        $scope   = _$scope_.$new()
    ]

  beforeEach ->
    inject ['$injector',
      ($injector) ->
        $http = $injector.get("$httpBackend")
        $http.expectGET('/api/user_repos').respond([testObj])

        repos = $injector.get("userRepoStore")
        $http.flush()
    ]
    expected = []

  describe "all()", ->

    it "should return all repos", ->
      $scope.$apply ->
        repos.all().then (its) ->
          expected = its
      expect(expected).toEqual [testObj]


  describe "sync()", ->

    beforeEach ->
      $http.expectPOST('/api/user_repos/sync').respond([testObj2])

    it "should send request to sync repos and replace current repos from response", ->
      $scope.$apply ->
        repos.sync().then (_) ->
          true

      $http.flush()

      $scope.$apply ->
        repos.all().then (its) ->
          expected = its

      expect(expected).toEqual [testObj2]


  describe "subscribe", ->

    beforeEach ->
      $http.expectPOST('/api/user_repos/1/subscribe').respond('success')

    it "should send POST request", ->
      $scope.$apply ->
        repos.toggleSubscribtion(id: 1, subscribed: true).then (it) ->
          expected = it
      $http.flush()
      expect(expected).toEqual 'success'


  describe "unsubscribe", ->

    beforeEach ->
      $http.expectPOST('/api/user_repos/1/unsubscribe').respond('success')

    it "should send POST request", ->
      $scope.$apply ->
        repos.toggleSubscribtion(id: 1, subscribed: false).then (it) ->
          expected = it
      $http.flush()
      expect(expected).toEqual 'success'


