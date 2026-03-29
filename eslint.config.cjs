const js = require("@eslint/js");
const { FlatCompat } = require("@eslint/eslintrc");
const eslintPluginNode = require("eslint-plugin-node");

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

module.exports = [
  ...compat.extends("universe/native", "universe/web"),
  {
    ignores: ["build"],
    // eslint-plugin-node is not compatible with ESLint 9 (context.getScope removal).
    // Disable node/* rules until the upstream config is updated.
    rules: Object.fromEntries(
      Object.keys(eslintPluginNode.rules).map((rule) => [`node/${rule}`, "off"])
    ),
  },
];
