import Foundation

/// Messages shown when a user selects a "continue for X minutes" option.
/// Templates include a `{MIN}` placeholder which is replaced with the selected minutes.
enum HealthBasedLimitMessages {
    enum Band: Int, CaseIterable, Sendable {
        case critical = 0   // 0–39
        case struggling = 1 // 40–59
        case worn = 2       // 60–79
        case healthy = 3    // 80–100
    }

    /// Maps ScrollKitty's health -> band using `CatState.from(health:)` thresholds (single source of truth).
    static func band(for health: Int) -> Band {
        switch CatState.from(health: health) {
        case .healthy:
            return .healthy
        case .concerned:
            return .worn
        case .tired:
            return .struggling
        case .weak, .dead:
            return .critical
        }
    }

    static func band(for state: CatState) -> Band {
        switch state {
        case .healthy:
            return .healthy
        case .concerned:
            return .worn
        case .tired:
            return .struggling
        case .weak, .dead:
            return .critical
        }
    }

    /// Returns the raw templates (containing `{MIN}`) for the provided band/minutes.
    static func templates(forBand band: Band, minutes: Int) -> [String] {
        templatesByBandAndMinutes[band]?[minutes] ?? []
    }

    /// Returns rendered messages for the provided band/minutes (with `{MIN}` replaced).
    static func messages(forBand band: Band, minutes: Int) -> [String] {
        templates(forBand: band, minutes: minutes).map { render($0, minutes: minutes) }
    }

    static func messages(forHealth health: Int, minutes: Int) -> [String] {
        messages(forBand: band(for: health), minutes: minutes)
    }

    static func messages(for state: CatState, minutes: Int) -> [String] {
        messages(forBand: band(for: state), minutes: minutes)
    }

    static func render(_ template: String, minutes: Int) -> String {
        template.replacingOccurrences(of: "{MIN}", with: String(minutes))
    }

    private static let templatesByBandAndMinutes: [Band: [Int: [String]]] = [
        .healthy: [
            5: [
                #"Okay. {MIN} minutes. I can live with that."#,
                #"{MIN} minutes. Quick dip, then back."#,
                #"Alright, {MIN} minutes. Don’t get cozy in there."#,
                #"{MIN} minutes. Keep it light for me."#,
                #"Fine. {MIN} minutes. No wandering."#,
                #"{MIN} minutes. I’m counting, gently."#,
                #"Cool. {MIN} minutes. Then we reset."#,
                #"{MIN} minutes. Come back before it grabs you."#,
                #"Alright. {MIN} minutes. You’ve got this."#,
                #"{MIN} minutes. I’ll be right here."#,
            ],
            10: [
                #"Oof. {MIN} minutes. Don’t let it stretch."#,
                #"{MIN} minutes… that tugged a little."#,
                #"Alright, {MIN} minutes. Please stop at the line."#,
                #"{MIN} minutes. Keep your promise."#,
                #"Okay. {MIN} minutes. Don’t drift."#,
                #"{MIN} minutes. In and out, yeah?"#,
                #"Fine. {MIN} minutes. Stay awake in there."#,
                #"{MIN} minutes. Come back on time."#,
                #"Alright. {MIN} minutes. Then done."#,
                #"{MIN} minutes… try not to sink."#,
            ],
            15: [
                #"{MIN} minutes is a lot of pull."#,
                #"Ow. {MIN} minutes. Be careful."#,
                #"Alright… {MIN} minutes. Don’t extend it."#,
                #"{MIN} minutes. Keep it contained."#,
                #"Okay. {MIN} minutes. No extra."#,
                #"{MIN} minutes… that stings a bit."#,
                #"Fine. {MIN} minutes. Then we stop."#,
                #"{MIN} minutes. Please don’t disappear."#,
                #"Alright. {MIN} minutes. Choose me after."#,
                #"{MIN} minutes. I’m watching the clock."#,
            ],
            30: [
                #"{MIN} minutes… that’s heavy."#,
                #"Ow. {MIN} minutes. Please don’t get lost."#,
                #"Alright… {MIN} minutes. Come back to me."#,
                #"{MIN} minutes. That’s a long time to vanish."#,
                #"Okay. {MIN} minutes. End it on time."#,
                #"{MIN} minutes… please don’t make it a habit."#,
                #"Fine. {MIN} minutes. I’ll wait."#,
                #"{MIN} minutes. Don’t let it swallow you."#,
                #"Alright. {MIN} minutes. Then we’re done."#,
                #"{MIN} minutes… be kind when you return."#,
            ],
        ],

        .worn: [
            5: [
                #"Thanks. {MIN} minutes feels manageable."#,
                #"{MIN} minutes. Please keep it tight."#,
                #"Alright, {MIN} minutes. Don’t stretch it."#,
                #"{MIN} minutes… I felt that, but okay."#,
                #"Fine. {MIN} minutes. Quick and clean."#,
                #"{MIN} minutes. No detours, please."#,
                #"Alright. {MIN} minutes. Then back to me."#,
                #"{MIN} minutes. I’m tired, so be gentle."#,
                #"Okay. {MIN} minutes. Don’t linger."#,
                #"{MIN} minutes. Come back soon."#,
            ],
            10: [
                #"Ow. {MIN} minutes is heavy for me."#,
                #"{MIN} minutes… please don’t extend it."#,
                #"Alright. {MIN} minutes. I’m holding on."#,
                #"{MIN} minutes. Hurry back."#,
                #"Okay… {MIN} minutes. That stung."#,
                #"Fine. {MIN} minutes. Keep your head up."#,
                #"{MIN} minutes. Don’t let it drag you."#,
                #"Alright, {MIN} minutes. Then we stop."#,
                #"{MIN} minutes… I’m low today."#,
                #"Okay. {MIN} minutes. Come back on time."#,
            ],
            15: [
                #"That hurts. {MIN} minutes is a lot right now."#,
                #"{MIN} minutes… please come back fast."#,
                #"Alright… {MIN} minutes. No more than that."#,
                #"Ow. {MIN} minutes. Be kind to me."#,
                #"{MIN} minutes. Don’t let it run."#,
                #"Okay. {MIN} minutes. Please mean it."#,
                #"Fine. {MIN} minutes. Then we end it."#,
                #"{MIN} minutes… I’m fading."#,
                #"Alright. {MIN} minutes. Choose me after."#,
                #"{MIN} minutes. Don’t disappear on me."#,
            ],
        ],

        .struggling: [
            5: [
                #"Ow. {MIN} minutes. Please keep your promise."#,
                #"{MIN} minutes… okay. Hurry back."#,
                #"Alright… {MIN} minutes. That still hurts."#,
                #"{MIN} minutes. No extensions, please."#,
                #"Fine. {MIN} minutes. Then stop."#,
                #"{MIN} minutes. I need you back."#,
                #"Okay. {MIN} minutes. Don’t drift."#,
                #"{MIN} minutes… I’m trying to hold on."#,
                #"Alright. {MIN} minutes. Be quick with it."#,
                #"{MIN} minutes. Please come back to me."#,
            ],
            10: [
                #"That really hurts. {MIN} minutes feels huge."#,
                #"{MIN} minutes… I’m shaking. Please stop there."#,
                #"Alright… {MIN} minutes. Then choose me."#,
                #"Ow. {MIN} minutes. I can’t take more."#,
                #"{MIN} minutes. Please come back on time."#,
                #"Okay. {MIN} minutes. No extra."#,
                #"{MIN} minutes… that’s scary today."#,
                #"Fine. {MIN} minutes. Don’t extend it."#,
                #"Alright. {MIN} minutes. Please be gentle."#,
                #"{MIN} minutes. Then we stop, okay?"#,
            ],
        ],

        .critical: [
            5: [
                #"I can’t take much. {MIN} minutes. Please come back."#,
                #"Ow… {MIN} minutes. That’s all I’ve got."#,
                #"{MIN} minutes… I’m barely here. Hurry."#,
                #"Okay… {MIN} minutes. Please don’t stretch it."#,
                #"{MIN} minutes. I need you back now."#,
                #"Ow. {MIN} minutes. That hurt deep."#,
                #"{MIN} minutes… please be gentle."#,
                #"Alright… {MIN} minutes. Then stop."#,
                #"{MIN} minutes. Please don’t leave me long."#,
                #"Okay. {MIN} minutes. Come back to me."#,
            ],
        ],
    ]
}

