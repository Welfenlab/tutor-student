var gulp        = require('gulp');
var source      = require('vinyl-source-stream');
var browserify  = require('browserify');
var less        = require('gulp-less');
var concat      = require('gulp-concat');
var watch       = require('gulp-watch');

// browserify bundle for direct browser use.
gulp.task("bundle", function(){
  bundler = browserify('./app/scripts/tutor.coffee',
    {
      transform: ['coffeeify','brfs'],
//      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: ['knockout-mapping']
    });

  return bundler.bundle()
    .on('error', function(err){ console.log(err.message); this.emit('end');})
    .pipe(source('tutor.js'))
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

gulp.task('watch', ['bundle'], function () {
    gulp.watch("./app/**/*.coffee", ['bundle']);
});
