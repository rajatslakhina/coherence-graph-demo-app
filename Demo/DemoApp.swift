import SwiftUI
import CoherenceGraph
import CoherenceGraphUI

/// Host app for the `CoherenceGraph` demo.
///
/// The app owns the compiled-in policy the library runs under — a real
/// dependency on the core module, not a decorative import.
///
/// `maxCascadeDepth` bounds how many follow-up transactions one user action may
/// trigger when a registered `CoherenceSink` writes back during publish. Being
/// precise about what that means here: **this demo registers no sink**, so no
/// cascade is reachable and the value is never exercised — it is the policy a
/// host app would have to choose, carried honestly rather than a number
/// presented as if it were doing work. The library's own cascade tests are
/// where the budget is actually driven to its limit.
@main
struct DemoApp: App {

    private static let policy = CoherencePolicy(maxCascadeDepth: 6)

    var body: some Scene {
        WindowGroup {
            CoherenceDemoView(policy: Self.policy)
        }
    }
}
