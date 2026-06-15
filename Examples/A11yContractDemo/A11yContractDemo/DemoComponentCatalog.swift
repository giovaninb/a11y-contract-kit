import A11yContractCore
import Foundation

struct DemoExpectedRule: Identifiable {
    let ruleId: String
    let severity: A11ySeverity
    let descriptionKey: String

    var id: String { ruleId }
}

struct DemoProblemExample: Identifiable {
    let componentId: String
    let titleKey: String
    let detailKey: String
    let rules: [DemoExpectedRule]

    var id: String { componentId }
}

struct DemoFixExample: Identifiable {
    let componentId: String
    let titleKey: String
    let summaryKey: String

    var id: String { componentId }
}

enum DemoComponentCatalog {
    static let problemExamples: [DemoProblemExample] = [
        DemoProblemExample(
            componentId: "delete_button",
            titleKey: "problems.card.delete.title",
            detailKey: "problems.card.delete.detail",
            rules: [
                DemoExpectedRule(ruleId: "ios-a11y-missing-label", severity: .critical, descriptionKey: "problems.card.delete.rule.label"),
                DemoExpectedRule(ruleId: "ios-a11y-missing-role", severity: .major, descriptionKey: "problems.card.delete.rule.role"),
                DemoExpectedRule(ruleId: "ios-a11y-touch-target-hig", severity: .info, descriptionKey: "problems.card.delete.rule.target"),
            ]
        ),
        DemoProblemExample(
            componentId: "favorite_button",
            titleKey: "problems.card.favorite.title",
            detailKey: "problems.card.favorite.detail",
            rules: [
                DemoExpectedRule(ruleId: "ios-a11y-missing-label", severity: .critical, descriptionKey: "problems.card.favorite.rule.label"),
                DemoExpectedRule(ruleId: "ios-a11y-missing-role", severity: .major, descriptionKey: "problems.card.favorite.rule.role"),
                DemoExpectedRule(ruleId: "ios-a11y-touch-target-hig", severity: .info, descriptionKey: "problems.card.favorite.rule.target"),
            ]
        ),
        DemoProblemExample(
            componentId: "low_contrast_label",
            titleKey: "problems.card.contrast.title",
            detailKey: "problems.card.contrast.detail",
            rules: [
                DemoExpectedRule(ruleId: "ios-a11y-low-contrast", severity: .critical, descriptionKey: "problems.card.contrast.rule.contrast"),
            ]
        ),
        DemoProblemExample(
            componentId: "fixed_font_label",
            titleKey: "problems.card.font.title",
            detailKey: "problems.card.font.detail",
            rules: [
                DemoExpectedRule(ruleId: "ios-a11y-fixed-font", severity: .major, descriptionKey: "problems.card.font.rule.font"),
            ]
        ),
    ]

    static let fixExamples: [DemoFixExample] = [
        DemoFixExample(
            componentId: "delete_button",
            titleKey: "fixed.card.delete.title",
            summaryKey: "fixed.card.delete.summary"
        ),
        DemoFixExample(
            componentId: "favorite_button",
            titleKey: "fixed.card.favorite.title",
            summaryKey: "fixed.card.favorite.summary"
        ),
        DemoFixExample(
            componentId: "status_label",
            titleKey: "fixed.card.status.title",
            summaryKey: "fixed.card.status.summary"
        ),
    ]
}
