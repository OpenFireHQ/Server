module.exports = (grunt) ->

  # Require all grunt plugins at once
  require('load-grunt-tasks')(grunt)

  ###
  # tasks
  ###
  grunt.registerTask 'lint',    [ 'coffeelint' ]
  grunt.registerTask 'test',    [ 'mochacov:spec', 'lint' ]
  grunt.registerTask 'cov',     [ 'mochacov:cov' ]
  grunt.registerTask 'default', [ 'test' ]
  grunt.registerTask 'build',   [ 'test', 'clean', 'coffee:dist' ]

  ###
  # config
  ###
  grunt.initConfig

    # Tests and coverage tests
    # When running cov you will need to pipe your output
    mochacov :
      travis :
        options : coveralls : serviceName : 'travis-ci'
      spec :
        options : reporter : 'spec'
      cov  :
        options : reporter : 'html-cov'
      options :
        compilers : [ 'coffee:coffee-script/register' ]
        files     : [ 'test/**/*.spec.coffee' ]
        require   : [ 'should' ]
        growl     : true
        ui        : 'tdd'
        bail      : true # Fail fast

    # Lint our coffee files
    # Linting is unobtrusive. If linting errors happen then they wont break the process
    coffeelint:
      options:
        force: true # Display lint errors as warnings. Do not break.
        configFile: 'coffeelint.json'
      files: [ 'test/**/*.coffee', 'src/**/*.coffee' ]


    # Watch for file changes.
    watch:
      lib:
        files : [ '**/*.coffee' ]
        tasks : [ 'test' ]
        options : nospawn : true

    # Clear the contents of a directory
    clean: [ 'dist']

    # Bump the version and build the tags
    bump:
      options:
        files  : [ 'package.json' ]
        commit : false
        push   : false

    # Deal with coffeescript concatenation and compiling
    coffee:
      options: join: true
      dist:
        files:
          'dist/openfireserver.js' : 'src/**/*.coffee'

