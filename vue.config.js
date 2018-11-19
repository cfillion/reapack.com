module.exports = {
  coffee: {
    bare: true,
    transpile: { presets: ['@babel/env'] },
  },
  sass: {
    includePaths: ['source/stylesheets'],
    indentedSyntax: true
  },
  customCompilers: {
    // see https://github.com/vuejs/vueify/pull/191
    coffee: function(raw, cb, compiler) {
      var coffee = require('coffeescript')
      var compiled
      try {
        compiled = coffee.compile(raw, compiler.options.coffee)
      } catch (err) {
        return cb(err)
      }
      cb(null, compiled)
    },
    slim: function(raw, cb, compiler) {
      var child_process = require('child_process')
      var compiled
      try {
        compiled = child_process.execSync('bundle exec slimrb', {
          encoding: 'utf8',
          input: raw
        })
      }
      catch(err) {
        return cb(err)
      }
      cb(null, compiled)
    }
  }
}
