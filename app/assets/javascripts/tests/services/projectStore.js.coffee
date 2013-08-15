describe "projectStore", ->

  $scope   = null
  projects = null
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

  evSource = eventSourceMock()

  beforeEach module("CI")

  beforeEach ->
    module ($provide) ->
      () ->
        $provide.value 'eventSource', evSource
    evSource.reset()

  beforeEach ->
    inject ['$rootScope',
      (_$scope_) ->
        $scope   = _$scope_.$new()
    ]

  beforeEach ->
    inject ['$injector',
      ($injector) ->
        $http    = $injector.get("$httpBackend")
        $http.expectGET("/api/projects").respond(angular.copy [testObj,testObj2])

        projects = $injector.get("projectStore")
    ]
    expected = []


  describe "all()", ->

    it "should return all projects", ->
      $scope.$apply ->
        projects.all().then (its) ->
          expected = its
      $http.flush()
      expect(expected).toEqual [testObj, testObj2]


  describe "one()", ->

    it "should find project by id", ->
      $scope.$apply ->
        projects.one(12).then (it) ->
          expected = it
      $http.flush()
      expect(expected).toEqual testObj


  describe "with eventSource", ->

    f = null

    beforeEach ->
      found = _.find evSource.subscriptions(), (it) ->
        it[0] == 'events.projects'
      f = found[1]

    beforeEach ->
      projects.all()
      $http.flush()

    it "should subscribe to 'events.projects'", ->
      names = evSource.subscriptions().map (it) ->
        it[0]
      expect(names).toContain 'events.projects'
      expect(f).toBeDefined()

    it "should add new project from event", ->
      e =
        action: 'created',
        data:
          id: 1
          name: "Created"
      f(e)
      $scope.$apply ->
        projects.all().then (its) ->
          expected = its[2]
      expect(expected).toEqual e.data

    it "should update project from event", ->
      e =
        action: 'updated',
        id: 12
        data:
          id: 12
          name: "sUpdated"
      f(e)
      $scope.$apply ->
        projects.all().then (its) ->
          expected = its[0]
      expect(expected.name).toEqual 'sUpdated'

    it "should destroy project from event", ->
      e =
        action: 'destroyed',
        id: 12
      f(e)
      $scope.$apply ->
        projects.all().then (its) ->
          expected = its
      expect(expected.length).toBe 1
      expect(expected.map((i) -> i.id)).toEqual [ 14 ]

