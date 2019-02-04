var utils = require('./utils')
var webpack = require('webpack')
var config = require('../config')
var merge = require('webpack-merge')
var baseWebpackConfig = require('./webpack.base.conf')
var MiniCssExtractPlugin = require('mini-css-extract-plugin')
var ExtractTextPlugin = require('extract-text-webpack-plugin')
var OptimizeCSSPlugin = require('optimize-css-assets-webpack-plugin')

module.exports = merge(baseWebpackConfig, {
  module: {
    rules: utils.styleLoaders({
      sourceMap: true,
      extract: true
    })
    // rules: utils.styleLoaders()
    // rules: [
    //   {
    //     test: /\.scss$/,
    //     use: ExtractTextPlugin.extract({
    //       fallback: 'style-loader',
    //       use: ['css-loader', 'sass-loader']
    //     })
    //   }
    // ]
  },
  externals: {
    vue: 'vue',
    lodash: 'lodash',
    'd3-drag': 'd3-drag',
    'd3-selection': 'd3-selection',
    'v-tooltip': 'v-tooltip',
    'd3-shape': 'd3-shape'
  },
  mode: 'production',
  entry: './src/index.js',
  output: {
    library: 'vueCurricula',
    libraryTarget: 'amd',
    // umdNamedDefine: true,
    filename: '../dist/vue-curricula.min.js'
  },
  optimization: {
    minimize: true
  },
  plugins: [
    // extract css into its own file
    new ExtractTextPlugin({
      filename: '../dist/vue-curricula.min.css'
    }),
    // Compress extracted CSS. We are using this plugin so that possible
    // duplicated CSS from different components can be deduped.
    new OptimizeCSSPlugin({
      cssProcessorOptions: {
        safe: true
      }
    }),
    // new webpack.optimize.UglifyJsPlugin({
    //   compress: {
    //     warnings: false
    //   },
    //   sourceMap: true
    // }),

    // new MiniCssExtractPlugin({
    //   filename: '../dist/vue-curricula.min.css'
    // })
  ]
})
