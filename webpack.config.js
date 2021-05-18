const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const path = require('path');
const webpack = require('webpack');

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
    sassOptions: {
      indentedSyntax: true,
      includePaths: ['source/stylesheets'],
    },
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
    extensions: ['.coffee', '.js'],
    fallback: {
      'path': require.resolve('path-browserify'),
    },
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
  plugins: [
    new webpack.ProvidePlugin({ process: 'process/browser' }),
    new VueLoaderPlugin(),
    new MiniCssExtractPlugin({ filename: 'stylesheets/upload-components.css' }),
  ],
};
