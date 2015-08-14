var gulp        = require('gulp');
var source      = require('vinyl-source-stream');
var browserify  = require('browserify');
var less        = require('gulp-less');
var concat      = require('gulp-concat');

// browserify bundle for direct browser use.
gulp.task("bundle", function(){
  bundler = browserify('./app/scripts/app.coffee',
    {
      transform: ['coffeeify','brfs'],
//      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: ['knockout-mapping']
    });

  return bundler.bundle()
    .pipe(source('app.js'))
    .pipe(gulp.dest('build'));
});

gulp.task("styles", function(){
  gulp.src("./app/styles/*.less")
    .pipe(less())
    .pipe(concat("style.css"))
    .pipe(gulp.dest('build'));
});

gulp.task("build", ["bundle","styles"]);

gulp.task("default", ["build"]);
