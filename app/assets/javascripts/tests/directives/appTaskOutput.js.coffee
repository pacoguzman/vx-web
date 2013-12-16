describe "appTaskDuration", ->

  $scope     = null
  $compile   = null
  $timeout   = null
  elem       = null
  item1      = null
  item2      = null

  beforeEach ->
    module("Vx")
    inject ['$rootScope', '$compile',
      (_$scope_, _$compile_, $injector) ->
        $scope   = _$scope_.$new()
        $compile = _$compile_
    ]

  beforeEach ->
    elem = angular.element('<span class="app-task-output" collection="collection">')
    $scope.collection = []
    $compile(elem)($scope)

  beforeEach ->
    item1 = {
      data: "log1",
      tm: 1
    }

    item2 = {
      data: "log2"
      tm: 2
    }

  describe "with empty collection", ->
    it "should have empty content", ->
      expect(elem.html()).toEqual ''

  describe "with collection", ->
    beforeEach ->
      $scope.collection.push item1
      $scope.$digest()

    it "should display log line", ->
      expected = '<div class="app-task-output-line">'
      expected += '<a class="app-tack-output-line-number" href="#L1"></a>'
      expected += '<span>log1</span>'
      expected += '</div>'
      expect(elem.html()).toEqual expected

    describe "and add line without '\\n'", ->
      it "should display merged log line", ->
        $scope.collection.push item2
        $scope.$digest()

        expected = '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number" href="#L1"></a>'
        expected += '<span>log1log2</span>'
        expected += '</div>'
        expect(elem.html()).toEqual expected

    describe "and add line with '\\n'", ->
      it "should display merged log lines", ->
        item2.data = "log2\n"
        item1.data = "log1\n"
        $scope.collection.push item2
        $scope.$digest()

        expected = '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number" href="#L1"></a>'
        expected += '<span>log1</span>'
        expected += '</div>'
        expected += '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number" href="#L2"></a>'
        expected += '<span>log2</span>'
        expected += '</div>'
        expected += '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number" href="#L3"></a>'
        expected += '<span>&nbsp;</span>'
        expected += '</div>'
        expect(elem.html()).toEqual expected


