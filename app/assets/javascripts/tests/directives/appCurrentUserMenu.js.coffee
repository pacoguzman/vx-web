describe "appCurrentUserMenu", ->

  $scope   = null
  $compile = null
  $http    = null
  elem     = null
  user     = {
    name: "user_name"
    companies: [
      {id: 1, name: "c1"},
      {id: 2, name: "c2"}
    ]
  }

  beforeEach ->
    module("Vx")
    inject ['$rootScope', '$compile', "$injector"
      (_$scope_, _$compile_, $injector) ->
        $scope   = _$scope_.$new()
        $compile = _$compile_
        $http    = $injector.get("$httpBackend")
    ]

  beforeEach ->
    $http.expectGET('/api/users/me').respond(user)

  beforeEach ->
    elem = angular.element('<div class="app-current-user-menu">')
    $compile(elem)($scope)

  it "should render menu", ->
    $http.flush()
    $scope.$digest()
    expect(elem.html()).toBe
    expect(elem.html()).toMatch 'user_name'
