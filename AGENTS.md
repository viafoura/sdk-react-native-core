# AGENTS.md

Guidance for AI agents and contributors working in this repository.

## Document everything

**Every change ships with its documentation.** A feature is not done when it
compiles — it is done when someone who did not write it can use it from the
README alone.

When you add or change anything user-facing, update in the same change:

- **`README.md`** — the public contract. Any new export, prop, event, native
  requirement or install step goes here. A new view needs its own section with a
  usage snippet and a prop table, and a row in the **Platform support** table.
- **`src/Viafoura.types.ts`** — exported TypeScript types for every prop and
  event payload. The types are documentation; consumers read them in their editor.
- **Behaviour that will surprise someone** — props read only at creation time,
  platform gaps, anything that needs a rebuild rather than a reload. Write it
  down next to the thing it applies to, not in a commit message.

When you change install, linking or build requirements, also check:

- **`README.md` → Requirements / Install** — both the bare React Native and the
  Expo path. This package supports both; documentation that covers only one is
  incomplete.
- **`.github/workflows/build.yml`** — CI smoke tests both integration paths. A
  new native requirement usually means a new CI step.

If a change is deliberately undocumented (internal refactor, no consumer-visible
effect), say so in the commit message so the omission reads as a decision.

## Code style

- **No comments that restate the code.** Comments explain *why* — a workaround, a
  non-obvious ordering constraint, an SDK quirk. The existing native files are the
  reference: each comment there earns its place.
- Match the surrounding file's conventions rather than introducing your own.

## Architecture

This package is a **classic React Native module**, not an Expo module. It
autolinks in bare React Native apps and in Expo prebuild apps from a single
implementation. Do not reintroduce `expo-modules-core`, `ExpoView`,
`ModuleDefinition` or `expo-module.config.json` — that would exclude bare
React Native consumers.

Layout:

| | |
| --- | --- |
| `src/` | TypeScript surface; `index.ts` is the public API |
| `ios/` | Swift views + `RCTViewManager` subclasses, exported via `RCT_EXTERN_MODULE` in the `.m` files |
| `android/src/main/java/com/viafoura/reactnative/` | Kotlin views + `ViewManager`s, registered in `ViafouraPackage.kt` |
| `Viafoura.podspec` | Must stay at the package root — iOS autolinking ignores `podspecPath` in `react-native.config.js` |
| `examples/bare/` | Bare React Native sample app |
| `examples/expo/` | Expo (prebuild) sample app; `ios/` and `android/` are generated, not committed |

Both samples depend on `"@viafoura/sdk-react-native": "file:../.."`, so they
always run the source in this checkout. Their `metro.config.js` watches the
repository root and disables hierarchical lookup so `react` resolves from the
sample's `node_modules` only — the symlinked package would otherwise pull the
root's copy in as well and every hook would throw. Run `npm install` at the
root before a sample: it builds `build/` and fetches the iOS xcframework.

A view manager class named `FooManager` exports the component as `Foo`: React
Native strips the `Manager` suffix, and that is also what makes the class work
through the Fabric interop layer. Keep the iOS and Android component names
identical, and use `RCT_REMAP_VIEW_PROPERTY` when a native property name has to
differ from the JavaScript prop.

## Verifying a change

Compiling is not evidence that it works. Before calling native work done:

1. `npm run build && npm run lint`
2. Build **both** sample apps, both platforms — `examples/bare` and
   `examples/expo`. CI does this on every PR.
3. **Run it.** Launch at least one app and confirm the view renders and the
   native modules resolve at runtime. Duplicate-React errors, missing view
   managers and initialization crashes are invisible to the compiler.

Check native SDK APIs against the shipped binaries rather than against older
code: `javap` on the Android AAR in the Gradle cache, and the
`.swiftinterface` inside `ios/ViafouraSDK.xcframework`.
