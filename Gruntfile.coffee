module.exports = (grunt) ->

  grunt.initConfig({
    jade: {
      debug: {
        options: {
          pretty: true,
          data: {
            styles: [
              'packages/bootstrap/css/bootstrap.css'
            ],
            scripts: [
              'packages/jquery/jquery.js'
              'packages/bootstrap/bootstrap.js'
            ]
          }
        },
        files: {
          'dist/index.html': 'src/index.jade'
        }
      }
    },
    less: {
      debug: {
        files: {
          'dist/packages/bootstrap/css/bootstrap.css': 'src/styles/bootstrap.less'
        }
      }
    },
    sync: {
      debug: {
        files: [
          {expand: true, flatten: true, src: 'bower_components/jquery/dist/jquery.js', dest: 'dist/packages/jquery'},
          {expand: true, flatten: true, src: 'bower_components/bootstrap/dist/js/bootstrap.js', dest: 'dist/packages/bootstrap'},
          {expand: true, flatten: true, src: 'bower_components/bootstrap/dist/fonts/*', dest: 'dist/packages/bootstrap/fonts'}
        ]
      }
    }
    watch: {
      jade: {
        files: ['src/**/*.jade'],
        tasks: ['jade:debug'],
        options: {
          atBegin: true
        }
      },
      less: {
        files: ['src/**/*.less'],
        tasks: ['less:debug'],
        options: {
          atBegin: true
        }
      },
      sync: {
        files: []
        tasks: ['sync:debug'],
        options: {
          atBegin: true
        }
      }
      configFiles: {
        files: ['Gruntfile.coffee'],
        options: {
          reload: true
        }
      }
    }
  })

  grunt.loadNpmTasks('grunt-contrib-jade');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-sync');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['sync:debug', 'jade:debug', 'less:debug']);
