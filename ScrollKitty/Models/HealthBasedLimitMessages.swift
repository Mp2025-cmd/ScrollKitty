import Foundation

/// Messages shown when a user selects a "continue for X minutes" option.
/// Templates include a `{MIN}` placeholder which is replaced with the selected minutes.
enum HealthBasedLimitMessages {
    
    /// Returns the raw templates (containing `{MIN}`) for the provided minutes.
    static func templates(forMinutes minutes: Int) -> [String] {
        templatesByMinutes[minutes] ?? []
    }
    
    /// Returns rendered messages for the provided minutes (with `{MIN}` replaced).
    static func messages(forMinutes minutes: Int) -> [String] {
        templates(forMinutes: minutes).map { render($0, minutes: minutes) }
    }
    
    static func render(_ template: String, minutes: Int) -> String {
        template.replacingOccurrences(of: "{MIN}", with: String(minutes))
    }
    
    private static let templatesByMinutes: [Int: [String]] = [
        5: [
            #"Ow. {MIN} minutes. I felt that. Come back on time."#,
            #"That stung. {MIN} minutes. Keep it small and return."#,
            #"Ouch. {MIN} minutes. Please stop at the line."#,
            #"I felt that hit. {MIN} minutes. Then back to me."#,
            #"Ow. {MIN} minutes. Quick pass. No extra."#,
            #"That landed. {MIN} minutes. Keep your exit in mind."#,
            #"Ouch. {MIN} minutes. In and out, okay?"#,
            #"I felt it. {MIN} minutes. Come back clean when it ends."#,
        ],
        
        10: [
            #"Ow. {MIN} minutes. That hurt. Please stop on time."#,
            #"Ouch. {MIN} minutes. I felt every bit of that. Come back on time."#,
            #"That stung. {MIN} minutes. Keep it tight. No extra."#,
            #"I felt that hit. {MIN} minutes. Please do not let it stretch."#,
            #"Ow. {MIN} minutes. Hold the line for me."#,
            #"Ouch. {MIN} minutes. Keep your exit close."#,
            #"That hurt. {MIN} minutes. Then done."#,
            #"I felt it. {MIN} minutes. Please do not drift."#,
        ],
        
        15: [
            #"Ow. {MIN} minutes. That really hurt. No extensions."#,
            #"Ouch. {MIN} minutes. That was heavy. Please come back on time."#,
            #"That stung hard. {MIN} minutes. Stop at the line."#,
            #"I felt that hit deep. {MIN} minutes. Keep it contained."#,
            #"Ow. {MIN} minutes. Please do not disappear in there."#,
            #"Ouch. {MIN} minutes. Hold your boundary."#,
            #"That hurt. {MIN} minutes. Come back when it ends."#,
            #"I felt it. {MIN} minutes. No extra minutes, please."#,
        ],
        
        30: [
            #"Ow. {MIN} minutes. That hurt a lot. Please come back on time."#,
            #"Ouch. {MIN} minutes. That was too much. Hold the line."#,
            #"That hit hard. {MIN} minutes. No extensions. Please."#,
            #"I felt that drain. {MIN} minutes. Do not let it turn into a loop."#,
            #"Ow. {MIN} minutes. Please do not get lost."#,
            #"Ouch. {MIN} minutes. Come back clean when it ends."#,
            #"That hurt. {MIN} minutes. Keep your exit in mind the whole time."#,
            #"I felt every bit of that. {MIN} minutes. Then back to me."#,
        ],
    ]
}
