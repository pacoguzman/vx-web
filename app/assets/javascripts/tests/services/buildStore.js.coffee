describe "buildStore", ->

  $scope   = null
  builds   = null
  $http    = null
  succVal  = null
  failVal  = null

  succ = (it) ->
    succVal = it

  fail = (it) ->
    failVal = it

  testObj = {
    id:   12
    name: "MyName"
  }

  testObj2 = {
    id:   14
    name: "MyName"
  }

  evSource = eventSourceMock()

  beforeEach module("Vx")

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
    succVal = failVal = null


  describe "create()", ->

    beforeEach ->
      $http.expectPOST('/api/projects/1/builds').respond('success')

    it "should send POST request", ->
      $scope.$apply ->
        builds.create(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual 'success'


  describe "restart()", ->
    loadedObj =
      a: "loaded"

    restartedObj =
      a: "restarted"

    it "should send PUT request", ->
      $http.expectGET('/api/builds/1').respond(loadedObj)
      $scope.$apply ->
        builds.one(1).then succ, fail
      $http.flush()
      expect(succVal.a).toEqual 'loaded'

      $http.expectPOST('/api/builds/1/restart').respond(restartedObj)
      $scope.$apply ->
        builds.restart(1)
      $http.flush()
      expect(succVal.a).toEqual 'restarted'

      builds.one(1).then succ, fail
      expect(succVal.a).toEqual 'restarted'

  describe "all()", ->

    beforeEach ->
      $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])

    it "should return all builds for project", ->
      $scope.$apply ->
        builds.all(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual [testObj, testObj2]

  describe "branches()", ->
    beforeEach ->
      $http.expectGET('/api/projects/1/branches').respond(angular.copy [testObj, testObj2])

    it "should return last build per branch for project", ->
      $scope.$apply ->
        builds.branches(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual [testObj, testObj2]

  describe "pullRequests()", ->
    beforeEach ->
      $http.expectGET('/api/projects/1/pull_requests').respond(angular.copy [testObj, testObj2])

    it "should return last build per pull_request for project", ->
      $scope.$apply ->
        builds.pullRequests(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual [testObj, testObj2]

  describe "queued()", ->
    beforeEach ->
      $http.expectGET('/api/builds/queued').respond(angular.copy [testObj, testObj2])

    it "should return all queued builds accross projects", ->
      $scope.$apply ->
        builds.queued().then succ, fail
      $http.flush()
      expect(succVal).toEqual [testObj, testObj2]

  describe "one()", ->

    beforeEach ->
      $http.expectGET('/api/builds/1').respond(testObj)

    it "should return one build", ->
      $scope.$apply ->
        builds.one(1).then succ, fail
      $http.flush()
      expect(succVal).toEqual testObj


  describe "with eventSource", ->

    f      = null
    before = null

    beforeEach ->
      [[_, f]] = evSource.subscriptions()

    it "should subscribe to 'builds'", ->
      [[name, _]] = evSource.subscriptions()
      expect(name).toEqual 'builds'
      expect(f).toBeDefined()

    describe "new build from event", ->

      describe "all()", ->

        beforeEach ->
          $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.all(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should add to collection if in same project", ->
          e =
            event: 'created',
            data:
              id: 1
              project_id: 1
              name: "Created"
          f(e)
          $scope.$apply ->
            builds.all(1).then succ, fail
          expect(succVal.length).toBe 3
          expect(succVal[2]).toEqual e.data

      describe "branches()", ->

        beforeEach ->
          testObj.branch = "master"
          testObj2.branch = "stable"

          $http.expectGET('/api/projects/1/branches').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.branches(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should add to branches collection if in same project and new branch", ->
          e =
            event: 'created',
            data:
              id: 1
              project_id: 1
              name: "Created"
              branch: "topic-branch"
          f(e)
          $scope.$apply ->
            builds.branches(1).then succ, fail
          expect(succVal.length).toBe 3
          expect(succVal[2]).toEqual e.data

        it "should substitute existing build for the branch if in same project", ->
          e =
            event: 'created',
            data:
              id: 1
              project_id: 1
              name: "Created"
              branch: "master"
          f(e)
          $scope.$apply ->
            builds.branches(1).then succ, fail
          expect(succVal.length).toBe 2
          expect(succVal[0]).toEqual testObj2
          expect(succVal[1]).toEqual e.data

      describe "queued()", ->

        beforeEach ->
          $http.expectGET('/api/builds/queued').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.queued().then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should add to queued collection (builds are created in this state)", ->
          e =
            event: 'created',
            data:
              id: 1
              project_id: 1
              name: "Created"
          f(e)
          $scope.$apply ->
            builds.queued().then succ, fail
          expect(succVal.length).toBe 3
          expect(succVal[2]).toEqual e.data

      describe "pullRequests()", ->

        beforeEach ->
          testObj.pull_request_id = 99
          testObj2.pull_request_id = 101

          $http.expectGET('/api/projects/1/pull_requests').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.pullRequests(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should add to pull_requests collection (has pull_request_id)", ->
          e =
            event: 'created',
            data:
              id: 1
              project_id: 1
              pull_request_id: 1
              name: "Created"
          f(e)
          $scope.$apply ->
            builds.pullRequests(1).then succ, fail
          expect(succVal.length).toBe 3
          expect(succVal[2]).toEqual e.data

        it "should substitute existing build for the branch if in same project", ->
          e =
            event: 'created',
            data:
              id: 1
              project_id: 1
              pull_request_id: 99
              name: "Created"
          f(e)
          $scope.$apply ->
            builds.pullRequests(1).then succ, fail
          expect(succVal.length).toBe 2
          expect(succVal[0]).toEqual testObj2
          expect(succVal[1]).toEqual e.data

    describe "destroy build from event", ->

      describe "all()", ->
        beforeEach ->
          $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.all(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should delete from collection if in same project", ->
          e =
            event: 'destroyed',
            id: 12
            data:
              project_id: 1
          f(e)
          $scope.$apply ->
            builds.all(1).then succ, fail
          expect(succVal.length).toBe 1
          expect(succVal[0].id).toEqual 14

      describe "branches()", ->
        beforeEach ->
          $http.expectGET('/api/projects/1/branches').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.branches(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should delete from collection if in same project", ->
          e =
            event: 'destroyed',
            id: 12
            data:
              project_id: 1
          f(e)
          $scope.$apply ->
            builds.branches(1).then succ, fail
          expect(succVal.length).toBe 1
          expect(succVal[0].id).toEqual 14

      describe "queued()", ->
        beforeEach ->
          $http.expectGET('/api/builds/queued').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.queued().then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should delete from collection", ->
          e =
            event: 'destroyed',
            id: 12
            data:
              project_id: 1
          f(e)
          $scope.$apply ->
            builds.queued().then succ, fail
          expect(succVal.length).toBe 1
          expect(succVal[0].id).toEqual 14

    describe "updated build from event", ->

      describe "(model)", ->
        beforeEach ->
          $http.expectGET('/api/builds/12').respond(angular.copy testObj)
          $scope.$apply ->
            builds.one(12).then succ, fail
          $http.flush()
          expect(succVal).toEqual testObj

        it "should update if found", ->
          e =
            event: 'updated',
            id: 12
            data:
              project_id: 1
              name: "xUpdated"
          f(e)
          $scope.$apply ->
            builds.one(12).then succ, fail
          expect(succVal.name).toEqual 'xUpdated'

      describe "(collection)", ->
        beforeEach ->
          $http.expectGET('/api/projects/1/builds').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.all(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should update if build found in collection", ->
          e =
            event: 'updated',
            id: 12
            data:
              project_id: 1
              name: "sUpdated"
          f(e)
          $scope.$apply ->
            builds.all(1).then succ, fail
          expect(succVal.length).toBe 2
          expect(succVal[0].name).toEqual 'sUpdated'
          expect(succVal[1].name).toEqual 'MyName'

      describe "(branches collection)", ->
        beforeEach ->
          $http.expectGET('/api/projects/1/branches').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.branches(1).then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should update if build found in collection", ->
          e =
            event: 'updated',
            id: 12
            data:
              project_id: 1
              name: "sUpdated"
          f(e)
          $scope.$apply ->
            builds.branches(1).then succ, fail
          expect(succVal.length).toBe 2
          expect(succVal[0].name).toEqual 'sUpdated'
          expect(succVal[1].name).toEqual 'MyName'

      describe "(queued collection)", ->
        beforeEach ->
          $http.expectGET('/api/builds/queued').respond(angular.copy [testObj, testObj2])
          $scope.$apply ->
            builds.queued().then succ, fail
          $http.flush()
          expect(succVal.length).toBe 2

        it "should update if build found in collection and still queued", ->
          e =
            event: 'updated',
            id: 12
            data:
              project_id: 1
              name: "sUpdated"
          f(e)
          $scope.$apply ->
            builds.queued().then succ, fail
          expect(succVal.length).toBe 2
          expect(succVal[0].name).toEqual 'sUpdated'
          expect(succVal[1].name).toEqual 'MyName'


        it "should remove if build found in collection and not queued anymore", ->
          e =
            event: 'updated',
            id: 12
            data:
              project_id: 1
              name: "sUpdated"
              finished_at: new Date()
          f(e)
          $scope.$apply ->
            builds.queued().then succ, fail
          expect(succVal.length).toBe 1
          expect(succVal[0].name).toEqual 'MyName'
