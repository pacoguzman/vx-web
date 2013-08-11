angular.module('CI').
filter('fromNow', function() {
  return function(dateString) {
    if (dateString) {
      return moment(dateString).fromNow()
    }
  };
});
