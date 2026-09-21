import SwiftUI
import CoherenceGraph
import CoherenceGraphUI

/// Host app for the `CoherenceGraph` demo.
///
/// The app owns the compiled-in policy the library runs under — this is a real
/// dependency on the core module, not a decorative import. `maxCascadeDepth`
/// is a product decision, not a library default: it bounds how many follow-up
/// transactions one user action may trigger when observers write back during
/// publish. Six is generous for a demo and still small enough that an
/// accidental feedback loop surfaces as a typed error within a frame rather
/// than as a hang.
@main
struct DemoApp: App {

    private static let policy = CoherencePolicy(maxCascadeDepth: 6)

    var body: some Scene {
        WindowGroup {
            CoherenceDemoView(policy: Self.policy)
        }
    }
}
