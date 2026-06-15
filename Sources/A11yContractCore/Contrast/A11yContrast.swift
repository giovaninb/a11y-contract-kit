import Foundation

public enum A11yContrast {
  public static func ratio(foreground: ColorComponents, background: ColorComponents) -> Double {
    let l1 = relativeLuminance(foreground)
    let l2 = relativeLuminance(background)
    let lighter = max(l1, l2)
    let darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)
  }

  public static func meetsMinimum(
    foreground: ColorComponents,
    background: ColorComponents,
    textSize: A11yTextSizeCategory = .normal,
    isGraphical: Bool = false
  ) -> Bool {
    meets(
      foreground: foreground,
      background: background,
      level: .aa,
      textSize: textSize,
      isGraphical: isGraphical
    )
  }

  public static func meetsEnhanced(
    foreground: ColorComponents,
    background: ColorComponents,
    textSize: A11yTextSizeCategory = .normal,
    isGraphical: Bool = false
  ) -> Bool {
    meets(
      foreground: foreground,
      background: background,
      level: .aaa,
      textSize: textSize,
      isGraphical: isGraphical
    )
  }

  public static func meets(
    foreground: ColorComponents,
    background: ColorComponents,
    level: WCAGLevel,
    textSize: A11yTextSizeCategory = .normal,
    isGraphical: Bool = false
  ) -> Bool {
    let currentRatio = ratio(foreground: foreground, background: background)
    if isGraphical {
      return currentRatio >= 3.0
    }
    switch level {
    case .a:
      return true
    case .aa:
      switch textSize {
      case .normal:
        return currentRatio >= 4.5
      case .large:
        return currentRatio >= 3.0
      }
    case .aaa:
      switch textSize {
      case .normal:
        return currentRatio >= 7.0
      case .large:
        return currentRatio >= 4.5
      }
    }
  }

  private static func relativeLuminance(_ color: ColorComponents) -> Double {
    func channel(_ value: Double) -> Double {
      let v = value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
      return v
    }
    let r = channel(color.red)
    let g = channel(color.green)
    let b = channel(color.blue)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
  }
}
