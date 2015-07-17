'use strict'

var gulp = require('gulp'),
    purescript = require('gulp-purescript'),
    browserify = require('gulp-browserify'),
    run = require('gulp-run'),
    runSequence = require('run-sequence'),
    plumber = require('gulp-plumber'),
    buffer = require('vinyl-buffer'),
    source = require('vinyl-source-stream');


function sequence () {
    var args = [].slice.apply(arguments);
    return function() {
        runSequence.apply(null, args);
    };
}

var sources = [
    'src/**/*.purs',
    'bower_components/purescript-*/src/**/*.purs'
];
var foreigns = [
    'src/**/*.js',
    'bower_components/purescript-*/src/**/*.js'
];

var testSources = [
    'test/src/**/*.purs'
];
var testForeigns = [
    'test/src/**/*.js'
];

var exampleSources = [
    'example/src/**/*.purs'
];

var exampleForeigns = [
    'example/src/**/*.js'
];

gulp.task('docs', function() {
    return purescript.pscDocs({
        src: sources,
        docgen: {
            "Text.Markdown.SlamDown": "docs/Text/Markdown/SlamDown.md",
            "Text.Markdown.SlamDown.Parser": "docs/Text/Markdown/SlamDown/Parser.md",
            "Text.Markdown.SlamDown.Pretty": "docs/Text/Markdown/SlamDown/Pretty.md",
            "Text.Markdown.SlamDown.Html": "docs/Text/Markdown/SlamDown/Html.md"
        }
    });
});


gulp.task('make', function() {
    return purescript.psc({
        src: sources,
        ffi: foreigns
    });
});

gulp.task('test-make', function() {
    return purescript.psc({
        src: sources.concat(testSources),
        ffi: foreigns.concat(testForeigns)
    });
});

gulp.task('example-make', function() {
    return purescript.psc({
        src: sources.concat(exampleSources),
        ffi: foreigns.concat(exampleForeigns)
    });
});


gulp.task('test-bundle',['test-make'], function () {
    return purescript.pscBundle({
        src: 'output/**/*.js',
        main: 'Test.Main',
        output: 'dist/test.js'
    });
});

gulp.task('example-bundle', ['example-make'], function() {
    return purescript.pscBundle({
        src: 'output/**/*.js',
        main: 'Main',
        output: 'dist/example.js'
    });
});

gulp.task('example', ['example-bundle'], function() {
    return browserify({
        entries: ['dist/example.js'],
        paths: ['node_modules']
    }).bundle()
        .pipe(plumber())
        .pipe(source('psc.js'))
        .pipe(buffer())
        .pipe(gulp.dest('example'));
});

gulp.task('test', ['test-bundle'], function() {
    run('node_modules/phantomjs/bin/phantomjs dist/test.js').exec();
});


gulp.task('default', sequence('make', 'docs'));
