require("dotenv").config();

module.exports = {
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {},
        },
      },
    ],
    plugins: [new webpack.EnvironmentPlugin(["targetPSN"])],
  },
};
