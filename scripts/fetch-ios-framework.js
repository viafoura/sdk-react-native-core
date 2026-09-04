const { execFileSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const root = path.join(__dirname, '..');
const version = require(path.join(root, 'package.json')).viafoura.iosSdkVersion;
const dest = path.join(root, 'ios', 'ViafouraSDK.xcframework');
const stamp = path.join(root, 'ios', '.viafourasdk-version');

if (fs.existsSync(dest) && fs.existsSync(stamp) && fs.readFileSync(stamp, 'utf8').trim() === version) {
  console.log(`ViafouraSDK.xcframework ${version} already present`);
  process.exit(0);
}

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'viafoura-sdk-ios-'));
try {
  execFileSync('git', [
    'clone', '--depth', '1', '--branch', version, '--quiet',
    'https://github.com/viafoura/sdk-ios.git', path.join(tmp, 'sdk-ios'),
  ], { stdio: 'inherit' });

  const src = path.join(tmp, 'sdk-ios', 'ViafouraSDK.xcframework');
  if (!fs.existsSync(src)) {
    throw new Error(`ViafouraSDK.xcframework not found in sdk-ios at tag ${version}`);
  }

  fs.rmSync(dest, { recursive: true, force: true });
  fs.cpSync(src, dest, { recursive: true });
  fs.writeFileSync(stamp, `${version}\n`);
  console.log(`Fetched ViafouraSDK.xcframework ${version}`);
} finally {
  fs.rmSync(tmp, { recursive: true, force: true });
}
