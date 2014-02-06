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
      data: "log1"
    }

    item2 = {
      data: "log2"
    }

  describe "with empty collection", ->
    it "should have empty content", ->
      expect(elem.html()).toEqual ''

  describe "with collection", ->

    it "should display log line", ->
      $scope.collection.push item1
      $scope.$digest()

      expected = '<div class="app-task-output-line">'
      expected += '<a class="app-tack-output-line-number"></a>'
      expected += '<span>log1</span>'
      expected += '</div>'
      expect(elem.html()).toEqual expected

    describe "and add line without '\\n'", ->
      it "should display merged log line", ->
        $scope.collection.push item1
        $scope.$digest()

        item2.data = "log2\n"
        $scope.collection.push item2
        $scope.$digest()

        item3 = {
          data: "log3\n"
        }
        $scope.collection.push item3
        $scope.$digest()

        expected = '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number"></a>'
        expected += "<span>log1log2\n</span>"
        expected += '</div>'
        expected += '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number"></a>'
        expected += "<span>log3\n</span>"
        expected += '</div>'
        expect(elem.html()).toEqual expected

    describe "and add line with '\\n'", ->
      it "should display merged log lines", ->
        item2.data = "log2\n"
        item1.data = "log1\n"

        $scope.collection.push item1
        $scope.$digest()
        $scope.collection.push item2
        $scope.$digest()

        expected = '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number"></a>'
        expected += "<span>log1\n</span>"
        expected += '</div>'
        expected += '<div class="app-task-output-line">'
        expected += '<a class="app-tack-output-line-number"></a>'
        expected += "<span>log2\n</span>"
        expected += '</div>'
        expect(elem.html()).toEqual expected


