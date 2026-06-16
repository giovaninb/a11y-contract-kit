#if canImport(UIKit)
import UIKit

/// Marks a view controller screen with the Swift source file used during audits.
public protocol A11yAuditable where Self: UIViewController {
    static var a11ySourceFile: String { get }
}
#endif
