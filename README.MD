1.package.json
	name 		:		项目名称
	description	:		简介
	author		:		作者，也就是你的名字

2.dirs.json

	%路径以"Gruntfile.js"为相对起点%

	source_path为源文件的根文件夹
	dest_path为项目运行文件的根文件夹

	css、js、coffee、less为其对应的文件夹

	如果不需要用less、coffee，那么css和js就要到source_path上对应的位置进行文件建立和代码编写

	jade则直接放在source_path的根目录上，该目录上有个jade文件夹，建议用以存放jade的模块(比如head和script的组件)
	如果不需要用jade，那么直接在source_path的根目录上存放html文件即可。

3.额外的文件就放在source_path的#{对应类型, 如js}的common中

4.上传
	sftp: {
		test: {
        	options: {
	        	path: '<%= secret.path %>/application/public',
	        	host: '<%= secret.host %>',
	        	username: '<%= secret.username %>',
	        	password: '<%= secret.password %>',
	        	showProgress: true,
	        	srcBasePath: "<%= dirs.dest_path %>",
	        	port: '<%= secret.port %>',
	        	createDirectories: true
        	},
	        files: {
	        	"./": ["<%= dirs.dest_path %><%= dirs.js %>main.js"]
	        }
    	}
	},

	path为服务器待上传的根路径，secret.path为WeTable的根目录，建议path填写要上传的文件们的共同路径，如：这里我要上传的css和js的共同是public。
	srcBasePath为告诉服务器，你上传的这堆文件，哪里是根目录。
	files的里的"./"不要管，右边的写法应是srcBasePath+"blablablabl"

	％以上代码为栗子％
	path如上代码，服务器将会被上传文件的根目录，就是public
	srcBasePath为我的dest_path，files的右边为dest_path的js中的main.js
	那么上传过程中，就会到服务器的public的根目录，然后把srcBasePath里待上传的文件依次上传。
	上传成功后，public里面就会有public/main.js

	命令行调用上传为: grunt sftp

5.安装配置和使用

	(osx加sudo) npm install
	grunt

