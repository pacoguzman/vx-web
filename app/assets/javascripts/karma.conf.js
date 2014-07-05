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
      "lib/underscore-1.5.2.js",
      "lib/moment-2.2.1.js",
      "lib/d3.v3-3.4.9.js",
      "lib/ansiparse.js",
      "lib/angular-1.2.11.js",
      "lib/angular-mocks-1.2.11.js",
      "lib/angular-route-1.2.11.js",
      "lib/ui-bootstrap-0.11.0.js",

      "templates.compilled.js",
      "vx/init/*.js.coffee",
      "vx/lib/*.js.coffee",
      "vx/directives/*.js.coffee",
      "vx/filters/*.js",
      "vx/services/*.js.coffee",

      "vx/tests/unit/support/*.js.coffee",
      "vx/tests/mock/*.js.coffee",
      "vx/tests/unit/**/*.js.coffee",
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
