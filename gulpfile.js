var gulp        = require('gulp');
var source      = require('vinyl-source-stream');
var browserify  = require('browserify');
var less        = require('gulp-less');
var concat      = require('gulp-concat');
var watch       = require('gulp-watch');
var disc        = require('disc');
var fs          = require('fs');

var libs = [
  "brace",
  "knockout",
  "knockout-mapping",
  "d3",
  "esprima",
  "dagre-d3",
  "markdown-it",
  "markdown-it-math",
  "async",
  "ascii2mathml",
  "i18next-ko",
  "graphlib-dot",
  "lodash"
];

// libs that are not used in production and thus can be removed
var devLibs = [
  "@tutor/dummy-auth"
]

function appBuildBundler(){
  bundler = browserify('./app/scripts/tutor.coffee',
    {
      transform: ['coffeeify','brfs'],
//      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: [require.resolve('knockout-mapping'), require.resolve('js-md5')],
      fullPaths: process.env.NODE_ENV != "production"
    });
  libs.forEach(function(lib) {
    bundler.external(lib);
  });

  if (process.env.NODE_ENV != "production"){
    // exclude dev libs in production build
    devLibs.forEach(function(lib){
      bundler.external(lib);
    });
  }

  return bundler.bundle()
}

function fullBuildBundler(){
  bundler = browserify('./app/scripts/tutor.coffee',
    {
      transform: ['coffeeify','brfs'],
//      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: [require.resolve('knockout-mapping'), require.resolve('js-md5')],
      fullPaths: process.env.NODE_ENV != "production"
    });

  return bundler.bundle()
}

// browserify bundle for direct browser use.
gulp.task("app", function(){
  appBuildBundler()
    .on('error', function(err){ console.log(err.message); this.emit('end');})
    .pipe(source('tutor.js'))
    .pipe(gulp.dest('build'));
});

function libsBuildBundler(){
  bundler = browserify({
      transform: ['coffeeify','brfs'],
  //      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: [require.resolve('knockout-mapping'), require.resolve('js-md5')],
      fullPaths: process.env.NODE_ENV != "production"
    });
  libs.forEach(function(lib) {
    bundler.require(lib);
  });

  return bundler.bundle()
}

gulp.task("build-libs", function(){
  libsBuildBundler()
    .on('error', function(err){ console.log(err.message); this.emit('end');})
    .pipe(source('vendor.js'))
    .pipe(gulp.dest('build'));
});

gulp.task("full",["build-full", "discify"]);

gulp.task("build-full", function(){
  fullBuildBundler()
    .on('error', function(err){ console.log(err.message); this.emit('end');})
    .pipe(source('full.js'))
    .pipe(gulp.dest('build'));
});

gulp.task("discify", function(){
  fullBuildBundler()
    .pipe(disc())
    .pipe(fs.createWriteStream('build/tutor.disc.html'));
  /* This does not work as externals are not supported...
  appBuildBundler()
    .pipe(disc())
    .pipe(fs.createWriteStream('build/tutor.disc.html'));

  libsBuildBundler()
    .pipe(disc())
    .pipe(fs.createWriteStream('build/vendor.disc.html'));
  */
});

gulp.task("bundle", ["build-libs", "app"]);

gulp.task("styles", function(){
  gulp.src("./app/styles/*.less")
    .pipe(less())
    .pipe(concat("style.css"))
    .pipe(gulp.dest('build'));
});

gulp.task("build", ["bundle","styles"]);

gulp.task("default", ["build"]);

gulp.task('watch', ['bundle'], function () {
    gulp.watch("./app/**/*.coffee", ['bundle']);
});
