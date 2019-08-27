const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

var babel = {
  loader: 'babel-loader',
  options: {
    cacheDirectory: true,
    presets: [
      ['@babel/preset-env', {
        targets: '> 0.25%, not dead, not ie <= 11',
        useBuiltIns: 'entry',
        corejs: 3,
      }],
    ],
  },
}

var coffee = {
  loader: 'coffee-loader',
  options: {
    bare: true,
  },
}

var sass = {
  loader: 'sass-loader',
  options: {
    indentedSyntax: true,
    includePaths: ['source/stylesheets'],
  },
}

module.exports = {
  mode: process.env.NODE_ENV,
  entry: {
    upload: './source/upload/main.coffee',
  },
  output: {
    filename: 'javascripts/[name].js',
    path: path.resolve(__dirname, '.webpack-build'),
  },
  resolve: {
    extensions: ['.coffee', '.js']
  },
  module: {
    rules: [
      { test: /\.coffee$/, use: [ babel, coffee ] },
      { test: /\.css$/,    use: [ MiniCssExtractPlugin.loader, 'css-loader' ] },
      { test: /\.js$/,     use: [ babel ] },
      { test: /\.sass$/,   use: [ MiniCssExtractPlugin.loader, 'css-loader', sass ] },
      { test: /\.slim$/,   use: [ './slim-loader.js' ] },
      { test: /\.vue$/,    use: [ 'vue-loader' ] },
    ],
  },
  devtool: process.env.NODE_ENV == 'production' ? false : 'inline-source-map',
  optimization: { minimize: false }, // middleman will take care of this
  plugins: [
    new VueLoaderPlugin(),
    new MiniCssExtractPlugin({ filename: 'stylesheets/upload-components.css' }),
  ],
};
