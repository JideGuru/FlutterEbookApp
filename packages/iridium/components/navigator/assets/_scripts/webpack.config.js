const path = require("path");

module.exports = {
  mode: "production",
  devtool: "eval-source-map",
  entry: {
    reflowable: "./src/index-reflowable.js",
    fixed: "./src/index-fixed.js",
  },
  output: {
    filename: "readium-[name].js",
    path: path.resolve(__dirname, "../readium/scripts"),
  },
  module: {
    rules: [
      {
        test: /\.m?js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-env"],
          },
        },
      },
    ],
  },
};
