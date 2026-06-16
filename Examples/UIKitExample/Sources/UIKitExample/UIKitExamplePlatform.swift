#if !canImport(UIKit)
/// Placeholder so the UIKitExample target compiles on macOS (CLI host).
public enum UIKitExamplePlatform {
    public static let requiresIOS = true
}
#endif
