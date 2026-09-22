const path = require('path');
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const projectRoot = __dirname;
const packageRoot = path.resolve(projectRoot, '..', 'sdk-react-native-core');

const escaped = packageRoot.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @viafoura/sdk-react-native is linked from a sibling checkout, so Metro has to
 * watch it. Its dev copies of react/react-native are blocked: Metro resolves from
 * the package's real path, so without this it loads React twice and the hook
 * dispatcher is null. Apps installing the package from npm need none of this.
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const config = {
  watchFolders: [packageRoot],
  resolver: {
    blockList: [
      new RegExp(`^${escaped}/node_modules/react/.*$`),
      new RegExp(`^${escaped}/node_modules/react-native/.*$`),
    ],
    extraNodeModules: {
      react: path.resolve(projectRoot, 'node_modules/react'),
      'react-native': path.resolve(projectRoot, 'node_modules/react-native'),
    },
  },
};

module.exports = mergeConfig(getDefaultConfig(projectRoot), config);
