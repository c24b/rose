'use strict'

module.exports = (grunt) ->
    require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

    yeomanConfig =
        app: 'app'
        dist: 'dist'
        kangoDist: 'dist/src/common'
        package: 'packages'

    grunt.initConfig
        yeoman: yeomanConfig
        watch:
            coffee:
                files: [
                    '<%= yeoman.app %>/scripts/{,**/}*.coffee'
                    '<%= yeoman.app %>/main.coffee'
                ]
                tasks: ['coffee']
            neuter:
                files: [
                    '<%= yeoman.app %>/main.js'
                    '.tmp/scripts/{,**/}*.js'
                ]
                tasks: ['neuter', 'livereload']
            locales:
                files: '<%= yeoman.app %>/popup/locales/**'
                tasks: ['copy', 'livereload']
            pages:
                files: '<%= yeoman.app %>/popup/pages/*.html'
                tasks: ['copy', 'livereload']
            templates:
                files: '<%= yeoman.app %>/res/templates/*.hbs'
                tasks: ['copy', 'livereload']
            htmlmin:
                files: [
                    '<%= yeoman.app %>/popup/{,**/}*.{html,js}'
                    '<%= yeoman.app %>/popup/styles/*.css'
                ]
                tasks: ['useminPrepare', 'htmlmin', 'usemin', 'livereload']

        coffee:
            dist:
                files: [
                    expand: true
                    cwd: '<%= yeoman.app %>/scripts'
                    src: '{,**/}*.coffee'
                    # dest: '<%= yeoman.kangoDist %>/scripts'
                    dest: '.tmp/scripts'
                    ext: '.js'
                ]
            main:
                files:
                    '<%= yeoman.app %>/main.js': '<%= yeoman.app %>/main.coffee'

        coffeelint:
            options:
                configFile: 'coffeelint.json'
            app: [
                'Gruntfile.coffee'
                'app/*.coffee'
                'app/scripts/**/*.coffee'
            ]

        useminPrepare:
            html: '<%= yeoman.app %>/popup/index.html'
            options:
                dest: '<%= yeoman.kangoDist %>/popup/'

        usemin:
            html: ['<%= yeoman.kangoDist %>/{,*/}*.html']
            css: ['<%= yeoman.kangoDist %>/styles/{,*/}*.css']
            options:
                dirs: ['<%= yeoman.kangoDist %>']

        htmlmin:
            dist:
                files: [
                    expand: true,
                    cwd: '<%= yeoman.app %>/popup/'
                    src: '*.html'
                    dest: '<%= yeoman.kangoDist %>/popup/'
                ]

        kangoManifest:
            dev:
                options:
                    buildnumber: false
                    background: 'background.js'
                src: '<%= yeoman.app %>'
                dest: '<%= yeoman.kangoDist %>'
            dist:
                options:
                    buildnumber: true
                    background: 'background.js'
                src: '<%= yeoman.app %>'
                dest: '<%= yeoman.kangoDist %>'

        neuter:
            options:
                template: "{%= src %}"
                filepathTransform: (filepath) ->
                    return '.tmp/scripts/' + filepath
            app:
                src: '.tmp/scripts/Starter.js'
                dest: '<%= yeoman.app %>/scripts/app.js'

        copy:
            dist:
                files: [
                    expand: true
                    dot: true
                    cwd: '<%= yeoman.app %>'
                    dest: '<%= yeoman.kangoDist %>'
                    src: [
                        'icons/{,*/}*.{webp,gif,png,svg}'
                        'res/{,**/}*.*'
                        'popup/templates/*.hbs'
                        'popup/styles/font/**'
                        'popup/locales/**'
                    ]
                ]

        open:
            chrome:
                path: 'http://reload.extensions'

        uglify:
            options:
                beautify: true
                mangle: false
                compress:
                    dead_code: true
                    drop_debugger: false

        clean:
            dist:
                files: [
                    dot: true
                    src: [
                        '<%= yeoman.kangoDist %>/*'
                        '<%= yeoman.app %>/scripts/app.js'
                        '<%= yeoman.app %>/main.js'
                        '<%= yeoman.package %>'
                        '.tmp'
                    ]
                ]

        shell:
            kangoBuild:
                command: 'kango.py build --output-directory <%= yeoman.package %> <%= yeoman.dist %>'

        jshint:
            all: [
                'Gruntfile.js'
                '<%= yeoman.app %>/popup/scripts/**/*.js'
                'test/**/*.js'
            ]

    grunt.registerTask 'test', [
        'jshint'
        'coffeelint'
    ]

    grunt.registerTask 'livereload', [
        'kangoManifest:dev'
        'concat'
        'uglify'
        'cssmin'
        'shell'
        'open'
    ]

    grunt.registerTask 'live', [
        'build'
        'open'
        'watch'
    ]

    grunt.registerTask 'build', [
        'test'
        'clean'
        'coffee'
        'neuter'
        'kangoManifest:dev'
        'useminPrepare'
        'htmlmin'
        'usemin'
        'concat'
        'uglify'
        'cssmin'
        'copy'
        'shell'
    ]

    grunt.registerTask 'dist', [
        'clean'
        'coffee'
        'neuter'
        'kangoManifest:dist'
        'useminPrepare'
        'htmlmin'
        'usemin'
        'concat'
        'uglify'
        'cssmin'
        'copy'
        'shell'
    ]

    grunt.registerTask 'default', [
        'build'
    ]