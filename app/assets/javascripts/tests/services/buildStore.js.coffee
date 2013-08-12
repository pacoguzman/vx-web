describe "buildStore", ->

  $scope   = null
  builds   = null
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
        $http  = $injector.get("$httpBackend")
        builds = $injector.get("buildStore")
    ]
    expected = []


  describe "all()", ->

    beforeEach ->
      $http.expectGET('/api/projects/1/builds').respond([testObj, testObj2])

    it "should return all builds for project", ->
      $scope.$apply ->
        builds.all(1).then (its) ->
          expected = its
      $http.flush()
      expect(expected).toEqual [testObj, testObj2]

    describe "twice", ->
      before = []

      describe "with same projectId", ->

        it "should reuse same collection", ->
          $scope.$apply ->
            builds.all(1).then (its) ->
              before = its
          $http.flush()
          expect(before.length).toBe 2

          $scope.$apply ->
            builds.all('1').then (its) ->
              expected = its
          expect(expected).toBe before

      describe "with another projectId", ->
        testObj3 =
          id: 99
          name: 'NewCollection'

        it "should create and return new collection", ->
          $scope.$apply ->
            builds.all(1).then (its) ->
              before = its
          $http.flush()
          expect(before.length).toBe 2

          $http.expectGET('/api/projects/2/builds').respond([testObj3])
          $scope.$apply ->
            builds.all(2).then (its) ->
              expected = its
          $http.flush()
          expect(expected).toNotBe before
          expect(expected).toEqual [testObj3]


  describe "one()", ->

    beforeEach ->
      $http.expectGET('/api/builds/1').respond(testObj)

    it "should return one build", ->
      $scope.$apply ->
        builds.one(1).then (b) ->
          expected = b
      $http.flush()
      expect(expected).toEqual testObj

    describe "twice", ->
      before = []

      describe "with same buildId", ->

        it "should reuse same model", ->
          $scope.$apply ->
            builds.one(1).then (b) ->
              before = b
          $http.flush()
          expect(before).toEqual testObj

          $scope.$apply ->
            builds.one('1').then (b) ->
              expected = b
          expect(expected).toBe before

      describe "with another buildId", ->

        it "should create and return new model", ->
          $scope.$apply ->
            builds.one(1).then (its) ->
              before = its
          $http.flush()
          expect(before).toEqual testObj

          $http.expectGET('/api/builds/2').respond(testObj2)
          $scope.$apply ->
            builds.one(2).then (its) ->
              expected = its
          $http.flush()
          expect(expected).toNotBe before
          expect(expected).toEqual testObj2

  describe "with eventSource", ->

    f = null

    beforeEach ->
      [[_, f]] = evSource.subscriptions()
      $http.expectGET('/api/projects/1/builds').respond([testObj, testObj2])

    it "should subscribe to 'events.projects'", ->
      [[name, _]] = evSource.subscriptions()
      expect(name).toEqual 'events.builds'
      expect(f).toBeDefined()

    describe "new build from event", ->
      before = null

      beforeEach ->
        $scope.$apply ->
          builds.all(1).then (its) ->
            before = its
        $http.flush()
        expect(before.length).toBe 2

      it "should add to collection if in same project", ->
        e =
          action: 'created',
          data:
            id: 1
            project_id: 1
            name: "Created"
        f(e)
        $scope.$apply ->
          builds.all(1).then (its) ->
            expected = its
        expect(expected.length).toBe 3
        expect(expected[2]).toEqual e.data

      it "should skip if build in other project", ->
        e =
          action: 'created',
          data:
            id: 1
            project_id: 2
            name: "Created"
        f(e)
        $scope.$apply ->
          builds.all(1).then (its) ->
            expected = its
        expect(expected.length).toBe 2
        expect(expected).toEqual [testObj, testObj2]

