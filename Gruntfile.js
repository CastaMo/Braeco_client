/*global module:false*/
module.exports = function(grunt) {

    var debounceDelay = 0;

    // LiveReload的默认端口号，你也可以改成你想要的端口号
    var lrPort = 35729;
    // 使用connect-livereload模块，生成一个与LiveReload脚本
    // <script src="http://127.0.0.1:35729/livereload.js?snipver=1" type="text/javascript"></script>
    var lrSnippet = require('connect-livereload')({
        port: lrPort
    });
    // 使用 middleware(中间件)，就必须关闭 LiveReload 的浏览器插件
    var serveStatic = require('serve-static');
    var serveIndex = require('serve-index');
    var md5File = require('md5-file');
    var lrMiddleware = function(connect, options, middlwares) {
        return [
            lrSnippet,
            // 静态文件服务器的路径 原先写法：connect.static(options.base[0])
            serveStatic(options.base[0]),
            // 启用目录浏览(相当于IIS中的目录浏览) 原先写法：connect.directory(options.base[0])
            serveIndex(options.base[0])
        ];
    };

    grunt.initConfig({
        // Task configuration.
        pkg: grunt.file.readJSON('package.json'),
        secret: grunt.file.readJSON('../secret.json'),
        dirs: grunt.file.readJSON('dirs.json'),


        connect: {
            options: {
                // 服务器端口号
                port: 8000,
                // 服务器地址(可以使用主机名localhost，也能使用IP)
                hostname: 'localhost',
                // 物理路径(默认为. 即根目录) 注：使用'.'或'..'为路径的时，可能会返回403 Forbidden. 此时将该值改为相对路径 如：/grunt/reloard。
                base: './bin'
            },
            livereload: {
                options: {
                    // 通过LiveReload脚本，让页面重新加载。
                    middleware: lrMiddleware,
                    options: {
                        script: "app.js"
                    }
                }
            }
        },
        express: {
            options: {
                // 服务器端口号
                port: 3000,
                // 服务器地址(可以使用主机名localhost，也能使用IP)
                hostname: 'localhost',
                // 物理路径(默认为. 即根目录) 注：使用'.'或'..'为路径的时，可能会返回403 Forbidden. 此时将该值改为相对路径 如：/grunt/reloard。
                base: '.'
            },
            livereload: {
                options: {
                    middleware: lrMiddleware,
                    livereload: true,
                    script: 'app.js'
                }
            }
        },

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
                src: ['bin/**/*.js', 'src/**/*.coffee']
            }
        },
        nodeunit: {
            files: ['test/**/*_test.js']
        },

        /*监控文件变化*/
        watch: {
            less: {
                options: {
                    livereload: lrPort,
                    debounceDelay: debounceDelay
                },
                files: '<%= dirs.source_path %><%= dirs.less %>/**/*.less',
                tasks: ['less']
            },
            coffee: {
                options: {
                    livereload: lrPort,
                    debounceDelay: debounceDelay
                },
                files: '<%= dirs.source_path %><%= dirs.coffee %>/**/*.coffee',
                tasks: ['coffee']
            },
            jade: {
                options: {
                    livereload: lrPort,
                    data: {
                        debug: true,
                        debounceDelay: debounceDelay,
                        timestamp: "<%= new Date().getTime() %>"
                    }
                },
                files: ['<%= dirs.source_path %>*.jade',
                        '<%= dirs.source_path %>jade/*.jade',
                        '!<%= dirs.source_path %>jade/*CSS.jade',
                        '!<%= dirs.source_path %>jade/*Script.jade',
                        '!<%= dirs.source_path %>jade/*JS.jade'],
                tasks: ['jade']
            },
            copy: {
                options: {
                    livereload: lrPort,
                    debounceDelay: debounceDelay
                },
                files: ['<%= dirs.source_path %>public/**/common/*',
                    '<%= dirs.source_path %>*.html',
                    '<%= dirs.source_path %><%= dirs.css %>*.css',
                    '<%= dirs.source_path %><%= dirs.js %>*.js'
                ],
                tasks: ['copy:build']
            }
        },


        /*清除文件*/
        clean: {
            build: {
                src: ["<%= dirs.dest_path %>"]
            },
            version: {
                src: ["<%= dirs.dest_path %>public/<%= dirs.version %>"]
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
                    '<%= dirs.dest_path %><%= dirs.js %>Client/main.min.js': ['<%= dirs.dest_path %><%= dirs.js %>Client/*.js', '!<%= dirs.dest_path %><%= dirs.js %>Client/*.min.js'],
                    '<%= dirs.dest_path %><%= dirs.js %>ClientCommon/extra.min.js': ['<%= dirs.dest_path %><%= dirs.js %>ClientCommon/*.js', '!<%= dirs.dest_path %><%= dirs.js %>ClientCommon/*.min.js']
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
                    '<%= dirs.dest_path %><%= dirs.css %>Client/main.min.css': ['<%= dirs.dest_path %><%= dirs.css %>Client/main.css'],
                    '<%= dirs.dest_path %><%= dirs.css %>Client/base64.min.css': ['<%= dirs.dest_path %><%= dirs.css %>Client/base64.css'],
                    '<%= dirs.dest_path %><%= dirs.css %>Client/common/extra.min.css': ['<%= dirs.dest_path %><%= dirs.css %>ClientCommon/*.css', '!<%= dirs.dest_path %><%= dirs.css %>ClientCommon/*.min.css']
                }
            }
        },

        /*复制预设文件，比如jquery，util*/
        copy: {
            build: {
                cwd: '<%= dirs.lib_path %>',
                src: ['<%= dirs.js %>**/*'],
                dest: '<%= dirs.dest_path %>',
                expand: true
            },

            versioncontrol: {
                options: {
                    process: function(content, srcpath) {

                        var versionPrefix = "/public/version";

                        var commonMap = {
                            utiljs: {
                                reg: /(?:\/public\/js\/)(\S+)(?:\/extra\.min\.js)((\?v=)(\w+))?/g,
                                path: 'bin/public/js/ClientCommon/extra.min.js',
                                prefix: '/public/js/ClientCommon/extra.min_',
                                type: '.js'
                            }
                        };

                        var pageMap = {
                            mainCss: {
                                reg: /(?:\/public\/css\/)(\S+)(?:\/main\.min\.css)(?:(?:\?v=)(?:\w+))?/g,
                                path: 'bin/public/css/{page}/main.min.css',
                                prefix: '/public/css/{page}/main.min_',
                                type: ".css"
                            },
                            base64Css: {
                                reg: /(?:\/public\/css\/)(\S+)(?:\/base64\.min\.css)(?:(?:\?v=)(?:\w+))?/g,
                                path: 'bin/public/css/{page}/base64.min.css',
                                prefix: '/public/css/{page}/base64.min_',
                                type: ".css"
                            },
                            mainJs: {
                                reg: /(?:\/public\/js\/)(\S+)(?:\/main\.min\.js)(?:(?:\?v=)(?:\w+))?/g,
                                path: 'bin/public/js/{page}/main.min.js',
                                prefix: '/public/js/{page}/main.min_',
                                type: ".js"
                            },
                        };

                        for (var key in commonMap) {
                            try {
                                content = content.replace(commonMap[key].reg, versionPrefix + commonMap[key].prefix + md5File(commonMap[key].path).substring(0, 10) + commonMap[key].type);
                            } catch(e) {
                                console.log(e);
                            }
                        }
                        for (var key in pageMap) {
                            var found = pageMap[key].reg.exec(content);

                            if (!found)
                                continue;

                            var file = pageMap[key].path.replace('{page}', found[1]),
                                fileMd5 = md5File(file).substring(0, 10),
                                prefix = pageMap[key].prefix.replace('{page}', found[1]);
                            type = pageMap[key].type

                            content = content.replace(found[0], versionPrefix + prefix + fileMd5 + type);
                        }
                        return content;
                    }
                },
                files: [{
                    src: "./bin/TableHome.php",
                    dest: './bin/Table/Main-54.html'
                }]
            }

        },

        /*编译jade，源文件路径设为src的根目录，src/jade里面装jade的option部分(比如你把head和script分离出来)，编译后放在bin中*/
        jade: {
            options: {
                data: {
                    debug: false,
                },
                pretty: true
            },
            test: {
                files: [{
                    expand: true,
                    cwd: '<%= dirs.source_path %>',
                    src: ['index.jade'],
                    dest: "<%= dirs.dest_path %>",
                    ext: ".html"
                }]
            },
            php: {
                files: {
                    "<%= dirs.dest_path %>TableHome.php": "<%= dirs.source_path %>formal.jade"
                }
            }
        },

        /*编译less，编译source里的less路径中所有less的文件，编译后放到dest里的css中*/
        less: {
            development: {
                options: {
                    compress: false,
                    yuicompress: false
                },
                files: {
                    "<%= dirs.dest_path %><%= dirs.css %>Client/main.css": ["<%= dirs.source_path %><%= dirs.less %>Client/main.less"],
                    "<%= dirs.dest_path %><%= dirs.css %>Client/base64.css": ["<%= dirs.source_path %><%= dirs.less %>Client/base64.less"]
                }
            }
        },

        /*编译coffee，编译source里的coffee路径中所有coffee的文件，编译后放到dest里的js中*/
        coffee: {
            compile: {
                options: {
                    bare: true,
                    join: true,
                    flatten: true
                },
                files: {
                    "<%= dirs.dest_path %><%= dirs.js %>Client/main.js": ["<%= dirs.source_path %><%= dirs.coffee %>Client/*.coffee"]
                }
            }
        },


        hashmap: {
            options: {
                // These are default options
                output: '#{= dest}/Client/hash.json',
                etag: null, // See below([#](#option-etag))
                algorithm: 'md5', // the algorithm to create the hash
                rename: '#{= dirname}/#{= basename}_#{= hash}#{= extname}', // save the original file as what
                keep: true, // should we keep the original file or not
                merge: false, // merge hash results into existing `hash.json` file or override it.
                hashlen: 10, // length for hashsum digest
            },
            map: {
                cwd: '<%= dirs.dest_path %>',
                src: ['<%= dirs.js %>**/*.min.js', '<%= dirs.css %>**/*.min.css'],
                dest: '<%= dirs.dest_path %>public/<%= dirs.version %>'
            }
        },


        /*好吧，这堆有点麻烦，看README.MD吧*/
        sftp: {
            options: {
                host: '<%= secret.host %>',
                username: '<%= secret.username %>',
                password: '<%= secret.password %>',
                showProgress: true,
                srcBasePath: "<%= dirs.dest_path %>",
                port: '<%= secret.port %>',
                createDirectories: true
            },
            module: {
                options: {
                    path: '<%= secret.path %>/application'
                },
                files: {
                    "./": ["<%= dirs.dest_path %>Table/**"]
                }
            },
            config: {
                options: {
                    path: '<%= secret.path %>/application'
                },
                files: {
                    "./": ["<%= dirs.dest_path %>public/<%= dirs.version %>**/main.min*.js",
                            "<%= dirs.dest_path %>public/<%= dirs.version %>**/extra.min*.js",
                            "<%= dirs.dest_path %>public/<%= dirs.version %>**/main.min*.css",
                            "<%= dirs.dest_path %>public/<%= dirs.version %>**/base64.min*.css",
                            "<%= dirs.dest_path %>public/<%= dirs.version %>**/hash.json"]
                }
            }
        },
        sshexec: {
            test: {
                command: [  'sh -c "cd /srv/www/WeTable; ls"',
                            'sh -c "ls"'],
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
    grunt.loadNpmTasks('grunt-hashmap');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-express-server');

    // Default task.
    grunt.registerTask('default', [
        'clean:build',
        'express',
        'copy:build',
        'less',
        'coffee',
        'jade',
        'watch'
    ]);
    grunt.registerTask('ready', [
        'copy:build',
        'less',
        'coffee',
        'uglify',
        'cssmin',
        'clean:version',
        'hashmap'
    ]);
    grunt.registerTask('upload', [
        'clean',
        'copy:build',
        'less',
        'coffee',
        'cssmin',
        'uglify',
        'clean:version',
        'hashmap',
        'jade',
        'copy:versioncontrol',
        'sftp'
    ]);
    grunt.registerTask('backup', [
        'copy:backup',
    ]);


};
