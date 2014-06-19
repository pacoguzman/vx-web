describe 'companyStore', ->
  companyStore = null
  $scope = null
  $http = null

  beforeEach ->
    module('Vx')

    inject ($rootScope) ->
      $scope = $rootScope.$new()

    inject ($injector) ->
      $http = $injector.get('$httpBackend')
      companyStore = $injector.get('companyStore')

  describe 'usage()', ->
    it 'sends GET request', ->
      $http.expectGET('/api/companies/usage').respond()
      $scope.$apply -> companyStore.usage()
