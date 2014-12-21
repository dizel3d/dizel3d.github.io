_ = require('lodash')
Mustache = require('mustache')

compileStrings = (obj, context) ->
  context = context || obj
  if _.isString(obj)
    return Mustache.render(obj, context)
  if _.isArray(obj)
    return _.map(obj, (value) -> compileStrings(value, context))
  if _.isObject(obj)
    return _.reduce(obj, ((newObj, value, key) ->
      newObj[key] = compileStrings(value, context)
      return newObj
    ), {})
  return obj

module.exports = (grunt) ->
  grunt.initConfig({
    less: {
      debug: {
        files: {
          'dist/styles.css': 'src/styles/styles.less'
        }
      }
    },
    sync: {
      debug: {
        files: [
          {expand: true, flatten: true, src: 'bower_components/jquery/dist/jquery.js', dest: 'dist/packages/jquery'},
          {expand: true, flatten: true, src: 'bower_components/angular/angular.js', dest: 'dist/packages/angular'},
          {expand: true, flatten: true, src: 'bower_components/angular-route/angular-route.js', dest: 'dist/packages/angular-route'},
          {expand: true, flatten: true, src: 'bower_components/bootstrap/dist/js/bootstrap.js', dest: 'dist/packages/bootstrap'},
          {expand: true, flatten: true, src: 'bower_components/bootstrap/dist/fonts/*', dest: 'dist/packages/bootstrap/fonts'}
          {expand: true, flatten: true, src: 'bower_components/ubuntu-fontface/fonts/*', dest: 'dist/packages/ubuntu-fontface/fonts'},
          {expand: true, flatten: true, src: 'src/app.js', dest: 'dist'},
          {expand: true, flatten: true, src: 'src/index.html', dest: 'dist'},
          {expand: true, flatten: true, src: 'src/pages/*', dest: 'dist/pages'}
        ]
      }
    }
    watch: {
      compileModels: {
        files: ['src/**/*.json'],
        tasks: ['compileModels'],
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
        files: ['src/app.js', 'src/**/*.html'],
        tasks: ['sync:debug'],
        options: {
          atBegin: true
        }
      }
      configFiles: {
        files: ['Gruntfile.coffee'],
        tasks: ['default'],
        options: {
          reload: true
        }
      }
    }
  })

  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-sync')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('compileModel', (lang) ->
    model = compileStrings(_.merge(
      grunt.file.readJSON('src/model.json'),
      grunt.file.readJSON('src/i18n/locale-' + lang + '.json')
    ), null, 2)
    grunt.file.write('dist/i18n/model-' + lang + '.json', JSON.stringify(model))
  )
  grunt.registerTask('compileModels', ['compileModel:en', 'compileModel:ru'])
  grunt.registerTask('default', ['compileModels', 'sync:debug', 'less:debug'])
