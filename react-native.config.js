module.exports = {
  dependency: {
    platforms: {
      ios: {},
      android: {
        sourceDir: './android',
        packageImportPath: 'import com.viafoura.reactnative.ViafouraPackage;',
        packageInstance: 'new ViafouraPackage()',
      },
    },
  },
};
