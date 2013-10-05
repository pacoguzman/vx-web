describe "appTaskDuration", ->

  $scope   = null
  $compile = null
  $timeout = null
  elem     = null
  task     = {}

  beforeEach ->
    module("CI")
    inject ['$rootScope', '$compile', '$injector'
      (_$scope_, _$compile_, $injector) ->
        $scope   = _$scope_.$new()
        $compile = _$compile_
        $timeout = $injector.get("$timeout")
    ]

  beforeEach ->
    elem = angular.element('<span class="app-task-duration" task="task">')
    $scope.task = _.clone task
    $compile(elem)($scope)

  describe "with empty task", ->
    it "should have empty content", ->
      expect(elem.html()).toEqual ''

  describe "with task", ->

    beforeEach ->
      $scope.$digest()

    describe 'and without started_at', ->
      it "should have empty content", ->
        expect(elem.html()).toEqual ''

    describe "and started_at", ->
      beforeEach ->
        $scope.task.started_at = new Date(0)
        $scope.$digest()

      it "should display duration", ->
        v0 = elem.html()
        expect(v0).toMatch /\d\d:\d\d/

        $timeout.flush()

        v1 = elem.html()
        expect(v1).toMatch /\d\d:\d\d/

    describe "and finished_at", ->
      beforeEach ->
        $scope.task.started_at = new Date(0)
        $scope.task.finished_at = new Date(65 * 1000)
        $scope.$digest()

      it "should display duration", ->
        v0 = elem.html()
        expect(v0).toEqual '01:05'
