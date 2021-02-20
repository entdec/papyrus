const path = require("path")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

module.exports = {
  mode: "production",
  entry: "./index.js",
  output: {
    path: __dirname + "/dist",
    filename: "papyrus.js",
    library: "papyrus",
    libraryTarget: "umd",
  },
  plugins: [
    // new CleanWebpackPlugin(['frontend/dist'],  {}),
    new MiniCssExtractPlugin({
      filename: "papyrus.css",
    }),
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        use: [
          {
            loader: "babel-loader",
            options: {
              presets: ["@babel/preset-env"],
              plugins: ["transform-class-properties"],
            },
          },
        ],
      },
      {
        test: /\.(png|jp(e*)g|svg)$/,
        use: [
          {
            loader: "url-loader",
            options: {
              limit: 8000, // Convert images < 8kb to base64 strings
              // name: 'images/[hash]-[name].[ext]'
            },
          },
        ],
      },
      {
        test: /\.(sass|scss|css)$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          "css-loader?sourceMap=false",
          "sass-loader?sourceMap=false",
        ],
      },
    ],
  },
  resolve: {
    modules: [path.resolve("./node_modules"), path.resolve("./")],
    extensions: [".json", ".js"],
  },
}
