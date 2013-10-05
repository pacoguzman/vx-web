describe "appBuildHttpUrl", ->

  $q       = null
  $scope   = null
  $compile = null
  elem     = null
  build    = {
    http_url: "http://example.com",
    sha: "HEAD",
  }


  beforeEach ->
    module("CI")
    inject ["$q", '$rootScope', '$compile',
      (_$q_, _$scope_, _$compile_) ->
        $q       = _$q_
        $scope   = _$scope_.$new()
        $compile = _$compile_
    ]

  beforeEach ->
    elem = angular.element('<span class="app-build-http-url" build="build">')
    $scope.build = _.clone build
    $compile(elem)($scope)

  describe "with empty build", ->
    it "should have empty content", ->
      expect(elem.html()).toEqual ''

  describe "with build", ->

    it "should have correct url", ->
      $scope.$digest()
      expect(elem.html()).toEqual '<a href="http://example.com">HEAD</a>'

    describe "and branch", ->

      beforeEach ->
        elem = angular.element('<span class="app-build-http-url" build="build" branch="true">')
        $scope.build.branch = 'master'
        $compile(elem)($scope)

      it "should have correct url", ->
        $scope.$digest()
        expect(elem.html()).toEqual '<a href="http://example.com">HEAD</a> (master)'

