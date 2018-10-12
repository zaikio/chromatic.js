var gulp   = require('gulp');
var coffee = require("gulp-coffee");
var uglify = require("gulp-uglify");
var concat = require("gulp-concat");
var del    = require('del');

gulp.task('coffee', function() {
  return gulp.src(['./src/views/**.coffee', './src/plugin.coffee'])
    .pipe(coffee())
    .pipe(concat('plugin.js'))
    .pipe(gulp.dest('./build'))
});

gulp.task('javascript', ['coffee'], function() {
  return gulp.src(['./src/lib/*.js', './build/plugin.js'])
    .pipe(concat('chromatic.js'))
    .pipe(gulp.dest('./dist'))
    .pipe(uglify())
    .pipe(concat('chromatic.min.js')) // renaming actually
    .pipe(gulp.dest('./dist'))
});

gulp.task('build-and-clean', ['javascript'], function() {
  del(['build']);
});

gulp.task('default', ['build-and-clean']);
