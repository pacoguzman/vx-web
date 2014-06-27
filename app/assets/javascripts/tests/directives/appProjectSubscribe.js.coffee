describe "appProjectSubscribe", ->

  $scope   = null
  $compile = null
  $http    = null
  elem     = null
  project  = null
  user     = null

  evSource = eventSourceMock()

  beforeEach ->
    module("Vx")

    module ($provide) ->
      () ->
        $provide.value 'eventSource', evSource
    evSource.reset()

    inject ['$rootScope', '$compile', "$injector"
      (_$scope_, _$compile_, $injector ) ->
        $scope   = _$scope_.$new()
        $compile = _$compile_
        $http    = $injector.get("$httpBackend")
    ]

  beforeEach ->

    project = {
      id: 1
    }

    user = {
      project_subscriptions: [1]
    }

  beforeEach ->
    $http.expectGET('/api/users/me').respond(user)

  beforeEach ->
    elem = angular.element('<div class="app-project-subscribe" project="project">')
    $scope.project = project
    $compile(elem)($scope)

  describe "when subscribed", ->

    it "should be", ->
      $http.flush()
      $scope.$digest()
      expect(elem.html()).toContain("fa-eye")

