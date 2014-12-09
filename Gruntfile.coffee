jade = require('jade')
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

  model = _.merge({
      styles: [
        'styles.css'
      ],
      scripts: [
        'packages/jquery/jquery.js'
        'packages/bootstrap/bootstrap.js'
      ]
    },
    grunt.file.readJSON('src/model.json'),
    grunt.file.readJSON('src/i18n/locale-en.json')
  )

  viewModel = compileStrings(model)
  viewModel._ = _
  viewModel.pretty = true
  viewModel.include = (path) => jade.renderFile('src/' + path + '.jade', viewModel)

  grunt.initConfig({
    jade: {
      debug: {
        options: {
          pretty: true,
          data: viewModel
        },
        files: {
          'dist/index.html': 'src/index.jade'
        }
      }
    },
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
          {expand: true, flatten: true, src: 'bower_components/bootstrap/dist/js/bootstrap.js', dest: 'dist/packages/bootstrap'},
          {expand: true, flatten: true, src: 'bower_components/bootstrap/dist/fonts/*', dest: 'dist/packages/bootstrap/fonts'}
          {expand: true, flatten: true, src: 'bower_components/ubuntu-fontface/fonts/*', dest: 'dist/packages/ubuntu-fontface/fonts'}
        ]
      }
    }
    watch: {
      printViewModel: {
        files: ['src/**/*.json'],
        tasks: ['printViewModel'],
        options: {
          atBegin: true
        }
      },
      jade: {
        files: ['src/**/*.jade', 'src/**/*.json'],
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

  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-sync')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('printViewModel', () -> grunt.file.write('dist/viewModel.json', JSON.stringify(viewModel, null, 2)))
  grunt.registerTask('default', ['printViewModel', 'sync:debug', 'jade:debug', 'less:debug'])
