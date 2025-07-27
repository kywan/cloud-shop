import postcssSimpleVars from "postcss-simple-vars"
import postcssNested from "postcss-nested"

export default {
  plugins: {
    "postcss-simple-vars": postcssSimpleVars(),
    "postcss-nested": postcssNested(),
  },
}
