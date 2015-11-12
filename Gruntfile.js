/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Task configuration.
    pkg: grunt.file.readJSON('package.json'),
    secret: grunt.file.readJSON('../secret.json'),
    dirs: grunt.file.readJSON('dirs.json'),

    //这坨东西不用管，init的时候送的
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        unused: true,
        boss: true,
        eqnull: true,
        globals: {}
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
      lib_test: {
        src: ['lib/**/*.js', 'test/**/*.js']
      }
    },
    nodeunit: {
      files: ['test/**/*_test.js']
    },

    /*监控文件变化*/
    watch: {
      less: {
        options: {
          debounceDelay: 250
        },
        files: '<%= dirs.source_path %><%= dirs.less %>/*.less',
        tasks: ['less', 'cssmin']
      },
      coffee: {
        options: {
          debounceDelay: 250
        },
        files: '<%= dirs.source_path %><%= dirs.coffee %>/*.coffee',
        tasks: ['coffee', 'uglify']
      },
      jade: {
        options: {
          data: {
            debug: true,
            debounceDelay: 250,
            timestamp: "<%= new Date().getTime() %>"
          }
        },
        files: ['<%= dirs.source_path %>*.jade', '<%= dirs.source_path %>**/*.jade'],
        tasks: ['jade']
      },
      copy: {
        options: {
          debounceDelay: 250
        },
        files: ['<%= dirs.source_path %>public/**/common/*',
                '<%= dirs.source_path %>*.html',
                '<%= dirs.source_path %><%= dirs.css %>*.css',
                '<%= dirs.source_path %><%= dirs.js %>*.js'],
        tasks: ['copy', 'uglify', 'cssmin']
      }
    },


    /*清除文件*/
    clean: {
      build: {
        src: ["<%= dirs.dest_path %>"]
      }
    },

    /*压缩js，把dest_path中的js路径里所有js都压缩为一个main.min.js*/
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n',
        report: "min"
      },
      dist: {
        files: {
          '<%= dirs.dest_path %><%= dirs.js %>main.min.js': ['<%= dirs.dest_path %><%= dirs.js %>*.js', '!<%= dirs.dest_path %><%= dirs.js %>*.min.js'],
          '<%= dirs.dest_path %><%= dirs.js %>common/extra.min.js': ['<%= dirs.dest_path %><%= dirs.js %>common/*.js', '!<%= dirs.dest_path %><%= dirs.js %>common/*.min.js']
        }
      }
    },

    /*把dest_path中的css路径里所有css都压缩为一个main.min.css*/
    cssmin: {
      options: {
        keepSpecialComments: 0,
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      compress: {
        files: {
          '<%= dirs.dest_path %><%= dirs.css %>main.min.css': ['<%= dirs.dest_path %><%= dirs.css %>*.css', '!<%= dirs.dest_path %><%= dirs.css %>*.min.css'],
          '<%= dirs.dest_path %><%= dirs.css %>common/extra.min.css': ['<%= dirs.dest_path %><%= dirs.css %>common/*.css', '!<%= dirs.dest_path %><%= dirs.css %>common/*.min.css']
        }
      }
    },

    /*复制预设文件，比如jquery，util*/
    copy: {
      build: {
        cwd: '<%= dirs.source_path %>',
        src: ['<%= dirs.js %>common/*', '<%= dirs.css %>common/*'],
        dest: '<%= dirs.dest_path %>',
        expand: true
      },
      origin: {
        cwd: '<%= dirs.source_path %>',
        src: ['<%= dirs.js %>*.js', '<%= dirs.css %>*.css', '*.html'],
        dest: '<%= dirs.dest_path %>',
        expand: true
      },

    },

    /*编译jade，源文件路径设为src的根目录，src/jade里面装jade的option部分(比如你把head和script分离出来)，编译后放在bin中*/
    jade: {
      debug: {
        options: {
          data: {
            debug: false,
          },
          pretty: true
        },
        files: [{
          expand: true,
          cwd: '<%= dirs.source_path %>',
          src: ['*.jade'],
          dest: "<%= dirs.dest_path %>",
          ext: ".html"
        }]
      }
    },

    /*编译less，编译source里的less路径中所有less的文件，编译后放到dest里的css中*/
    less: {
      development: {
        options: {
          compress:false,
          yuicompress:false
        },
        files: [{
          expand: true,
          cwd: '<%= dirs.source_path %><%= dirs.less %>',
          src: ['*.less'],
          dest: '<%= dirs.dest_path %><%= dirs.css %>',
          ext: '.css'
        }]
      }
    },

    /*编译coffee，编译source里的coffee路径中所有coffee的文件，编译后放到dest里的js中*/
    coffee: {
      compile: {
        options: {
          bare: true
        },
        files: [{
          expand: true,
          flatten: true,
          cwd: '<%= dirs.source_path %><%= dirs.coffee %>',
          src: ['*.coffee'],
          dest: '<%= dirs.dest_path %><%= dirs.js %>',
          ext: '.js'
        }]
      }
    },


    /*好吧，这堆有点麻烦，看README.MD吧*/
    sftp: {
      test: {
        options: {
          path: '<%= secret.path %>/application/public',
          host: '<%= secret.host %>',
          username: '<%= secret.username %>',
          password: '<%= secret.password %>',
          showProgress: true,
          srcBasePath: "<%= dirs.dest_path %><%= dirs.js %>",
          port: '<%= secret.port %>',
          createDirectories: true
        },
        files: {
          "./": ["<%= dirs.dest_path %><%= dirs.js %>main.js"]
        }
      }
    },
    sshexec: {
      test: {
        command: ['sh -c "cd /srv/www/WeTable; ls"'],
        options: {
          host: '<%= secret.host %>',
          username: '<%= secret.username %>',
          password: '<%= secret.password %>'
        }
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-nodeunit');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-jade');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-ssh');

  // Default task.
  grunt.registerTask('default', [
                    'copy',
                    'less',
                    'coffee',
                    'uglify',
                    'cssmin',
                    'jade',
                    'watch']);

};
