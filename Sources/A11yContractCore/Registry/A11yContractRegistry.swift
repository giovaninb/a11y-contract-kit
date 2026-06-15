import Foundation

public final class A11yContractRegistry: @unchecked Sendable {
    public static let shared = A11yContractRegistry()

    private var specs: [A11ySpec] = []
    private let lock = NSLock()

    private init() {}

    public func register(_ spec: A11ySpec) {
        lock.lock()
        defer { lock.unlock() }
        specs.append(spec)
    }

    public func allSpecs() -> [A11ySpec] {
        lock.lock()
        defer { lock.unlock() }
        return specs
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        specs.removeAll()
    }
}
