const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

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
      { test: /\.coffee$/, use: [
        {
          loader: 'coffee-loader',
          options: {
            bare: true,
            transpile: { presets: ['@babel/env'] },
          },
        },
      ]},
      { test: /\.vue$/,    use: 'vue-loader' },
      { test: /\.sass$/,   use: [
        MiniCssExtractPlugin.loader,
        'css-loader',
        {
          loader: 'sass-loader',
          options: {
            indentedSyntax: true,
            includePaths: ['source/stylesheets'],
          }
        },
      ]},
      { test: /\.slim$/,   use: './slim-loader.js' },
    ]
  },
  devtool: process.env.NODE_ENV == 'production' ? false : 'inline-source-map',
  optimization: { minimize: false }, // middleman will take care of this
  plugins: [
    new VueLoaderPlugin(),
    new MiniCssExtractPlugin({ filename: 'stylesheets/upload-components.css' }),
  ],
};
