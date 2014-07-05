describe "appLastBuildsChart", ->

  $scope   = null
  $compile = null
  $timeout = null
  elem     = null
  project  = null

  beforeEach ->
    module("Vx")
    inject ['$rootScope', '$compile', '$injector'
      (_$scope_, _$compile_, $injector) ->
        $scope   = _$scope_.$new()
        $compile = _$compile_
        $timeout = $injector.get("$timeout")
    ]
    elem = angular.element('<div class="app-last-builds-chart" project="project">')
    $scope.project = {
      last_builds: []
    }
    $compile(elem)($scope)

  it "should be empty if builds list empty", ->
    $scope.$digest()
    expect(elem.html()).toEqual '<svg style="width: 100%; height: 100%; "><g scale="(0,0)"></g></svg>'

  it "should render chart with in progress builds", ->
    b1 = { status: 3, duration: 11 }
    b2 = { started_at: (new Date).toString(), status: 2 }
    $scope.$digest()

    $scope.project.last_builds.push b1
    $scope.project.last_builds.push b2
    $scope.$digest()

    expect(elem.find("rect").length).toEqual 2
    expect(elem.find("rect").eq(0).attr("height")).toEqual '100%'
    expect(elem.find("rect").eq(1).attr("height")).toEqual '10%'
    expect(elem.find("rect").eq(0).attr("y")).toEqual '0%'
    expect(elem.find("rect").eq(1).attr("y")).toEqual '90%'

    b2.started_at = (new Date - 3000) # 3 seconds ago
    $timeout.flush()

    expect(elem.find("rect").eq(0).attr("height")).toEqual '100%'
    expect(elem.find("rect").eq(1).attr("height")).toEqual '27%'
    expect(elem.find("rect").eq(0).attr("y")).toEqual '0%'
    expect(elem.find("rect").eq(1).attr("y")).toEqual '73%'

  it "should render chart with finished builds", ->
    b1 = { status: 3, duration: 11 }
    b2 = { status: 3, duration: 7  }
    $scope.$digest()

    $scope.project.last_builds.push b1
    $scope.$digest()
    expect(elem.find("rect").length).toEqual 1
    expect(elem.find("rect").attr("x")).toEqual '90%'
    expect(elem.find("rect").attr("width")).toEqual '10%'
    expect(elem.find("rect").attr("height")).toEqual '100%'
    expect(elem.find("rect").attr("y")).toEqual '0%'

    $scope.project.last_builds.push b2
    $scope.$digest()
    expect(elem.find("rect").length).toEqual 2
    expect(elem.find("rect").eq(0).attr("x")).toEqual '90%'
    expect(elem.find("rect").eq(1).attr("x")).toEqual '80%'
    expect(elem.find("rect").eq(0).attr("width")).toEqual '10%'
    expect(elem.find("rect").eq(1).attr("width")).toEqual '10%'
    expect(elem.find("rect").eq(0).attr("height")).toEqual '100%'
    expect(elem.find("rect").eq(1).attr("height")).toEqual '64%'
    expect(elem.find("rect").eq(0).attr("y")).toEqual '0%'
    expect(elem.find("rect").eq(1).attr("y")).toEqual '36%'

