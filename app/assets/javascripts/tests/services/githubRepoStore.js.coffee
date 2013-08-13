describe "githubRepoStore", ->

  $scope   = null
  repos    = null
  $http    = null
  expected = null

  testObj = {
    id:   12
    name: "MyName"
  }

  testObj2 = {
    id:   14
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
        $http = $injector.get("$httpBackend")
        $http.expectGET('/api/github_repos').respond([testObj])

        repos = $injector.get("githubRepoStore")
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
      $http.expectPOST('/api/github_repos/sync').respond([testObj2])

    it "should send request to sync repos and replace current repos from response", ->
      $scope.$apply ->
        repos.sync().then (_) ->
          true

      $http.flush()

      $scope.$apply ->
        repos.all().then (its) ->
          expected = its

      expect(expected).toEqual [testObj2]


  describe "subscribe()", ->

    beforeEach ->
      $http.expectPOST('/api/github_repos/1/subscribe').respond('success')

    it "should send POST request", ->
      $scope.$apply ->
        repos.subscribe(1).then (it) ->
          expected = it
      $http.flush()
      expect(expected).toEqual 'success'


  describe "unsubscribe()", ->

    beforeEach ->
      $http.expectPOST('/api/github_repos/1/unsubscribe').respond('success')

    it "should send POST request", ->
      $scope.$apply ->
        repos.unsubscribe(1).then (it) ->
          expected = it
      $http.flush()
      expect(expected).toEqual 'success'


