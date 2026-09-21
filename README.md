# CoherenceGraph — Demo App

**Drag the quantity slider. The left panel publishes a cart that never existed. The right panel refuses to.**

This is the runnable iOS app for **[CoherenceGraph](https://github.com/rajatslakhina/coherence-graph-kit)**, which it consumes as a *remote* Swift package pinned to a released version — not a local path, and not `main`.

---

## What you are looking at

The app builds the same four-node graph twice:

```
          cart
         /    \
   subtotal    tax
         \    /
         total
```

Both graphs are live and get identical writes. The difference is only in *when* each one lets an observer look.

**Left — `NaivePropagator` (depth-first push).** One write produces **two** published states. The first is computed from a new `subtotal` and a *stale* `tax`. Every row spells out which quantity each value actually came from, because that is the only visible tell: the glitched row reads `quantity is 4, but subtotal came from 4 and tax came from 3 — the two branches disagree`, while its three money values add up perfectly. Then it settles, correctly — which is precisely why this bug survives code review, QA, and a bug report that says "the totals flicker sometimes."

**Right — `CoherenceEngine` (ordered commit).** One write produces **one** published state, and it is a consistent function of the source every time.

Below the panels the app runs `GraphAudit` live and renders the real findings. One row is *expected to fail*: the check is run against the deliberately broken propagator, because a check nobody has seen fail is not evidence of anything.

## Why this matters more during a migration

In a single-stack SwiftUI app you usually get away with the glitch — SwiftUI coalesces at the frame boundary and the inconsistent intermediate often never reaches the screen.

During a UIKit → SwiftUI migration you have **two propagation engines over one source of truth**, and neither can see the other's in-flight state. Now it does reach the screen: a UIKit cell and a SwiftUI view rendering two different answers from the same data in the same frame.

The "Single-writer ownership" section demonstrates the other half of the answer, and it has two buttons because a migration has two distinct verbs.

*Write as the other stack* attempts a write attributed to whichever stack does not own the cart domain, and shows you the typed error it gets back — accidental dual ownership is refused.

*Migrate* hands the domain over deliberately and appends to a visible transfer history. That separation is the point: `claim` throwing on a re-claim is what makes dual ownership impossible, so moving a domain during a migration cannot reuse it and gets its own verb, with an audit trail.

The library also guarantees **minimal publish**: writing the value a node already holds produces no snapshot at all, while the naive propagator, which has no equality pruning, republishes regardless. The app handles that case and explains it in the panel, but it is reached only if SwiftUI re-invokes the slider binding with an unchanged value — so treat it as covered by the library's tests and the audit, not as something this README promises you will see. Nobody has run this app (see below).

## Screenshots

**There are none, and this repository deliberately does not contain a `Demo/Screenshots/` directory.**

The app was built by an unattended scheduled job that is refused interactive control of this machine, so it was never launched on a Simulator and nothing was captured. Writing "see screenshot below" next to an image that does not exist would be worse than saying this plainly.

What *did* happen is in [Verification](#verification), stated separately, because **"compiles for an iOS Simulator destination" is not "ran on a Simulator"** and the two must not be blurred together.

## How to run it

```bash
git clone https://github.com/rajatslakhina/coherence-graph-demo-app.git
cd coherence-graph-demo-app
open Demo.xcodeproj
```

Then in Xcode: select the **Demo** scheme, pick any iOS Simulator, and ⌘R.

On first open Xcode resolves `coherence-graph-kit` from GitHub at the pinned version — no local checkout of the library is needed, and none is referenced. The first human ⌘R is genuinely this app's first launch.

## Verification

- **`Demo.xcodeproj` is structurally sound**, checked mechanically rather than by eye: brace/paren balance computed with strings and comments excluded, and all **23** objects confirmed both defined and referenced — no dangling object ids. `Demo.xcscheme` parses as XML and its `BlueprintIdentifier` resolves to the app target in the project.
- **CI ([Actions](https://github.com/rajatslakhina/coherence-graph-demo-app/actions))** runs `xcodebuild -resolvePackageDependencies`, fails the job if no `Package.resolved` is produced or if it does not reference `coherence-graph-kit`, prints the resolved version, and then compiles the app with `xcodebuild build -destination 'generic/platform=iOS Simulator'`. That is the cheapest honest substitute for a human opening the project: it proves the **remote** package genuinely resolves from GitHub at the pinned tag and that the app compiles against it.
- **The app was never run on a Simulator and no screenshots exist.** See above.

### Two deliberate CI choices

`generic/platform=iOS Simulator`, never `name=iPhone 16,OS=latest`. Pinning to a named device ties the job to whichever simulator *runtimes* happen to be installed on that day's runner image, which is not guaranteed — a compile-only check needs no device to exist.

`Package.resolved` is **not** committed. Letting CI resolve from scratch on every run is the stronger proof: it demonstrates that the tag resolves from GitHub *today*, rather than replaying a lockfile recorded once.

## Why two repositories

The library repo contains **no app target of any kind** — no executable product, no `.xcodeproj`. This app lives in its own repository and consumes the library exactly the way anyone else would: `XCRemoteSwiftPackageReference` against the public GitHub URL, `upToNextMajorVersion` from a released tag.

Pinning to a version rather than `branch = main` is the point. Branch-tracking means every clone and every CI run resolves whatever `main` happened to be that day, which is the wrong default for something meant to be reproducible.

## License

MIT
