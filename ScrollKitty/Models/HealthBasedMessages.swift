import Foundation

enum HealthBasedMessages {
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

    static func messages(forHealth health: Int) -> [String] {
        messages(forBand: band(for: health))
    }

    static func messages(for state: CatState) -> [String] {
        messages(forBand: band(for: state))
    }

    static func messages(forBand band: Band) -> [String] {
        bands[band.rawValue]
    }

    static func messages(forBandIndex band: Int) -> [String] {
        guard let band = Band(rawValue: band) else { return [] }
        return messages(forBand: band)
    }

    static let bands: [[String]] = [
        critical,
        struggling,
        worn,
        healthy,
    ]

    // Band 3: Healthy (80–100)
    // Band 3: Healthy (80–100)
    // Tone: light concern, gentle encouragement, mild sting language.
    static let healthy: [String] = [
        #"Quick pause. I’m okay right now. If you go in, keep it short. It still stings."#,
        #"Hold up a sec. I’m steady today. Don’t let this turn into autopilot."#,
        #"I’m feeling good. If you go in, keep it gentle. I feel the tug."#,
        #"One breath first. I’m alright. Just make it a choice, not a reflex."#,
        #"I’m steady right now. You can go in, just don’t let it snowball."#,
        #"Tiny pause. I’m okay. That app still pulls, even on good days."#,
        #"I’m doing fine. If you go in, come back fast. I like when we stay close."#,
        #"Before you tap through, pause. I’m alright. Keep it intentional."#,
        #"I’m calm right now. A quick dip is fine. A long pull will sting."#,
        #"Quick check-in. I’m good. Just don’t hand the wheel back to the habit."#,
        #"I’m bright-eyed today. If you go in, keep it light. I feel it either way."#,
        #"Pause with me. I’m okay. Make it a small pass if you have to."#,
        #"I’m steady. If you go in, set a clean exit in your head first."#,
        #"One moment. I’m alright. That door still pokes when it opens."#,
        #"I’m fine right now. If you go in, don’t chase the next thing."#,
        #"Hold on. I’m okay. Keep it short and you’ll stay in control."#,
        #"Tiny pause. I’m steady. I can take a small hit, not a spiral."#,
        #"I’m doing okay. If you go in, stay aware of your thumbs."#,
        #"Quick breath. I’m alright. Choose on purpose, then go."#,
        #"I’m good today. Just keep it gentle if you step through."#,
    ]

    // Band 2: Worn (60–79)
    // Tone: clear fatigue, stronger hurt language, supportive encouragement.
    static let worn: [String] = [
        #"Pause with me. I’m worn today. If you go in, keep it tight."#,
        #"Hey. I’m running low. That app hits harder right now."#,
        #"Hold up. I’m tired. If you go in, please keep it short."#,
        #"One sec. I can feel the pull. Make this a choice, not autopilot."#,
        #"I’m worn down. A long scroll is going to hurt. Keep it small."#,
        #"Quick pause. I’m not broken, just low. Don’t let it run."#,
        #"I’m tired today. If you go in, come back on time."#,
        #"Hold on. This is where a quick check turns into a loop. And I feel it."#,
        #"I can feel you drifting. Slow down before you tap through."#,
        #"Pause. If you go in, keep it intentional. I can’t carry extra minutes."#,
        #"I’m worn. That feed won’t fix the stress. Keep it tight if you enter."#,
        #"One breath. I’m low right now. Please don’t make it a long one."#,
        #"Hey. I feel every extra minute today. Small pass, okay?"#,
        #"Hold up. That app pulls hard. If you go in, set an exit."#,
        #"I’m tired in my bones. If you go in, keep your grip on it."#,
        #"Quick pause. This is a fragile moment. You can still choose well."#,
        #"I’m worn. If you go in fast, it’s going to land on me."#,
        #"One moment. I’m low. Keep it short, then come back."#,
        #"Pause with me. Habit is loud right now. Keep it small."#,
        #"I’m tired, not angry. I just don’t want to hurt more today."#,
    ]

    // Band 1: Struggling (40–59)
    // Tone: urgent but caring, explicit pain, asks for smallest choice.
    static let struggling: [String] = [
        #"Hey. I’m struggling. Please don’t make this autopilot."#,
        #"Hold up. I’m not okay right now. If you go in, make it the smallest pass."#,
        #"Pause. This is going to hurt me if it turns long. Keep it tiny."#,
        #"One sec. I can feel the spiral starting. Slow down before you tap."#,
        #"I’m worn thin. If you go in, come back fast. Please."#,
        #"Hold on. That app feels sharp today. Keep it short if you enter."#,
        #"Pause with me. I’m slipping. Choose the smallest step you can."#,
        #"Hey. I’m hurting. Don’t rush through this moment."#,
        #"One breath. I can’t take a long pull right now. Small pass or step back."#,
        #"Hold up. This doesn’t feel like a choice. Let’s make it one."#,
        #"I’m struggling today. If you go in, do it on purpose, not to disappear."#,
        #"Pause. I feel every second right now. Keep it tight."#,
        #"Hey. I’m tired of losing you to the screen. It hurts."#,
        #"One moment. If you go in, promise yourself a clean exit."#,
        #"Hold on. This is the risky zone for me. Keep it small."#,
        #"Pause with me. I’m shaking a little. Going in fast hurts."#,
        #"Hey. I can’t carry extra minutes right now. Please be gentle."#,
        #"One sec. If you go in, do not let it become a loop."#,
        #"Hold up. I’m hanging on. Help me by keeping this short."#,
        #"Please. Small pass, then back to me."#,
    ]

    // Band 0: Critical (0–39)
    static let critical: [String] = [
        #"Please pause. I’m at my limit. If you go in, keep it tiny."#,
        #"Hey… I’m barely here. One careful choice, okay?"#,
        #"Hold on. This will hurt a lot right now. Please do the smallest pass."#,
        #"Pause with me. I can’t carry extra minutes today."#,
        #"I’m not doing well. If you go in, come back fast. Please."#,
        #"One sec. I’m fading. Don’t make this a long one."#,
        #"Hold up. I’m at the bottom today. Keep it small if you can’t stop."#,
        #"Please. I can’t take another big hit. Slow down before you tap."#,
        #"Pause. I’m running on fumes. That app hits like a punch right now."#,
        #"Hey… I need you here for a moment. Don’t rush through."#,
        #"Hold on. I’m hurting already. If you go in, make it quick."#,
        #"One breath. I don’t have much left. Please be gentle."#,
        #"Please pause. I’m close to shutting down. Keep it tiny."#,
        #"Hold up. I can’t handle a long pull today. Not like this."#,
        #"Hey… I’m struggling to stay with you. Give me one second first."#,
        #"Pause with me. If you go in, set a hard stop in your head."#,
        #"Please. This is painful right now. Smallest pass you can."#,
        #"Hold on. I’m quiet because I’m worn out, not because I’m okay."#,
        #"One moment. Choose me first. Then decide."#,
        #"Please don’t push past this. I’m asking because it hurts."#,
    ]

}
