describe "userIdentitiesStore", ->

  $scope       = null
  identities   = null
  $http        = null
  succVal      = null
  failVal      = null

  succ = (it) ->
    succVal = it

  fail = (it) ->
    failVal = it

  testObj = {
    id:   1
    provider: "github"
    login: "github login"
    url: "github url"
  }

  testObj2 = {
    id:   2
    provider: "gitlab"
    login: "gitlab login"
    url: "gitlab url"
  }

  params = {
    id: 1
    login: "login",
    password: "password",
    url: "url"
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
        $http  = $injector.get("$httpBackend")
        identities = $injector.get("userIdentitiesStore")
    ]
    succVal = failVal = null


  describe "gitlab.create()", ->

    beforeEach ->
      $http.expectPOST('/api/user_identities/gitlab').respond('success')

    it "should send POST request", ->
      $scope.$apply ->
        identities.gitlab.create(params).then succ, fail
      $http.flush()
      expect(succVal.data).toEqual 'success'

  describe "gitlab.update()", ->

    beforeEach ->
      $http.expectPATCH('/api/user_identities/gitlab/1').respond(testObj2)

    it "should send PATCH request", ->
      $scope.$apply ->
        identities.gitlab.update(params).then succ, fail
      $http.flush()
      expect(succVal.data).toEqual testObj2

  describe "gitlab.destroy()", ->

    collection = [testObj, testObj2]

    beforeEach ->
      $http.expectDELETE('/api/user_identities/gitlab/1').respond("")

    it "should send DELETE request", ->
      $scope.$apply ->
        identities.gitlab.destroy(testObj, collection).then succ, fail
      $http.flush()
      expect(succVal.data).toEqual ""
      expect(collection).toEqual [testObj2]
