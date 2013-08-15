// Karma configuration
// Generated on Mon Aug 12 2013 15:08:00 GMT+0400 (MSK)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '',

    // frameworks to use
    frameworks: ["jasmine"],


    // list of files / patterns to load in the browser
    files: [
      "lib/jquery-2.0.3.js",
      "lib/underscore-1.4.4.js",
      "lib/moment-2.1.0.js",
      "lib/angular-1.2.0rc1.js",
      "lib/angular-route-1.2.0rc1.js",
      "lib/angular-mocks-1.1.5.js",

      "ci/init/*.js.coffee",
      "ci/factories/*.js.coffee",
      "ci/services/*.js.coffee",

      "tests/support/*.js.coffee",
      "tests/**/*.js.coffee",
    ],


    // list of files to exclude
    exclude: [

    ],

    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['dots'],

    preprocessors: {
      '**/*.coffee': 'coffee'
    },

    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['PhantomJS'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false,

    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: true,
        sourceMap: false
      },
      // transforming the filenames
      transformPath: function(path) {
        return path.replace(/\.js$/, '.coffee');
      }
    },

  });
};
