/* global process */
var gulp = require('gulp')
var source = require('vinyl-source-stream')
var buffer = require('vinyl-buffer')
var browserify = require('browserify')
var uglify = require('gulp-uglify')
var less = require('gulp-less')
var concat = require('gulp-concat')
var watch = require('gulp-watch')
var disc = require('disc')
var fs = require('fs')
var collapse = require('bundle-collapser/plugin')

var libs = [
  'knockout',
  'knockout-mapping',
  'd3',
  'nvd3',
  'esprima',
  'dagre-d3',
  'markdown-it',
  'markdown-it-math',
  'async',
  'ascii2mathml',
  'i18next-ko',
  'graphlib-dot',
  'lodash'
]

// libs that are not used in production and thus can be removed
var devLibs = [
  '@tutor/dummy-auth'
]

function appBuildBundler () {
  var bundler = browserify('./app/scripts/tutor.coffee',
    {
      transform: ['coffeeify', 'brfs'],
      //      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: [require.resolve('knockout-mapping')],
      fullPaths: process.env.NODE_ENV != 'production'
    })
  libs.forEach(function (lib) {
    bundler.external(lib)
  })

  if (process.env.NODE_ENV != 'production') {
    // exclude dev libs in production build
    devLibs.forEach(function (lib) {
      bundler.external(lib)
    })
  }

  return bundler.plugin(collapse).bundle()
}

function fullBuildBundler () {
  var bundler = browserify('./app/scripts/tutor.coffee',
    {
      transform: ['coffeeify', 'brfs'],
      //      standalone: 'tutor',
      extensions: ['.coffee'],
      debug: false,
      noParse: [require.resolve('knockout-mapping')],
      fullPaths: process.env.NODE_ENV != 'production'
    })

  return bundler.plugin(collapse).bundle()
}

// browserify bundle for direct browser use.
gulp.task('app', function () {
  var tutorjs = appBuildBundler()
    .on('error', function (err) { console.log(err.message); this.emit('end');})
    .pipe(source('tutor.js'))
  if (process.env.NODE_ENV == 'production') {
    tutorjs = tutorjs.pipe(buffer()).pipe(uglify())
  }
  tutorjs.pipe(gulp.dest('build'))
})

function libsBuildBundler () {
  var bundler = browserify({
    transform: ['coffeeify', 'brfs'],
    //      standalone: 'tutor',
    extensions: ['.coffee'],
    debug: false,
    noParse: [require.resolve('knockout-mapping')],
    fullPaths: process.env.NODE_ENV != 'production'
  })
  libs.forEach(function (lib) {
    bundler.require(lib)
  })

  return bundler.plugin(collapse).bundle()
}

gulp.task('build-libs', function () {
  var vendorlibs = libsBuildBundler()
    .on('error', function (err) { console.log(err.message); this.emit('end');})
    .pipe(source('vendor.js'))
  if (process.env.NODE_ENV == 'production') {
    vendorlibs = vendorlibs.pipe(buffer()).pipe(uglify())
  }
  vendorlibs.pipe(gulp.dest('build'))
})

gulp.task('full', ['build-full', 'discify'])

gulp.task('build-full', function () {
  fullBuildBundler()
    .on('error', function (err) { console.log(err.message); this.emit('end');})
    .pipe(source('full.js'))
    .pipe(gulp.dest('build'))
})

gulp.task('discify', function () {
  fullBuildBundler()
    .pipe(disc())
    .pipe(fs.createWriteStream('build/tutor.disc.html'))
/* This does not work as externals are not supported...
appBuildBundler()
  .pipe(disc())
  .pipe(fs.createWriteStream('build/tutor.disc.html'))

libsBuildBundler()
  .pipe(disc())
  .pipe(fs.createWriteStream('build/vendor.disc.html'))
*/
})

gulp.task('bundle', ['build-libs', 'app'])

gulp.task('styles', function () {
  var NpmImportPlugin = require('less-plugin-npm-import')

  gulp.src('./app/styles/*.less')
    .pipe(less({
      plugins: [new NpmImportPlugin()]
    }))
    .pipe(concat('style.css'))
    .pipe(gulp.dest('build'))
})

gulp.task('build', ['bundle', 'styles'])

gulp.task('default', ['build'])

gulp.task('watch', ['bundle'], function () {
  gulp.watch('./app/**/*.coffee', ['bundle'])
})
