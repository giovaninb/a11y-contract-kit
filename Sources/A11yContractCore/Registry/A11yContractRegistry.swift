import Foundation

public final class A11yContractRegistry: @unchecked Sendable {
    public static let shared = A11yContractRegistry()

    private var specs: [A11ySpec] = []
    private var sources: [String: A11ySource] = [:]
    private let lock = NSLock()

    private init() {}

    public func register(_ spec: A11ySpec) {
        lock.lock()
        defer { lock.unlock() }
        specs.append(spec)
        if let source = spec.source {
            sources[spec.id] = source
        }
    }

    public func registerSource(_ source: A11ySource, forComponentId componentId: String) {
        lock.lock()
        defer { lock.unlock() }
        sources[componentId] = source
    }

    public func source(forComponentId componentId: String) -> A11ySource? {
        lock.lock()
        defer { lock.unlock() }
        return sources[componentId]
    }

    public func spec(forComponentId componentId: String) -> A11ySpec? {
        lock.lock()
        defer { lock.unlock() }
        return specs.last { $0.id == componentId }
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
        sources.removeAll()
    }
}
