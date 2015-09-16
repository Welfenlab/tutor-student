var gulp        = require('gulp');
var source      = require('vinyl-source-stream');
var browserify  = require('browserify');
var less        = require('gulp-less');
var concat      = require('gulp-concat');
var watch       = require('gulp-watch');

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

// browserify bundle for direct browser use.
gulp.task("app", function(){
  bundler = browserify('./app/scripts/tutor.coffee',
    {
      transform: ['coffeeify','brfs'],
//      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: ['knockout-mapping'],
      fullPaths: true
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
    .on('error', function(err){ console.log(err.message); this.emit('end');})
    .pipe(source('tutor.js'))
    .pipe(gulp.dest('build'));
});

gulp.task("build-libs", function(){
  bundler = browserify({
      transform: ['coffeeify','brfs'],
  //      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: ['knockout-mapping']
    });
  libs.forEach(function(lib) {
    bundler.require(lib);
  });

  return bundler.bundle()
    .on('error', function(err){ console.log(err.message); this.emit('end');})
    .pipe(source('vendor.js'))
    .pipe(gulp.dest('build'));
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
