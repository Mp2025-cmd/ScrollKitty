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
    static let healthy: [String] = [
        #"Hey. I’m doing alright. Let’s not mess up a good streak."#,
        #"Quick pause. You’ve been steady today."#,
        #"I’m feeling good right now. Can we keep it gentle?"#,
        #"Before you open it, breathe with me for a second."#,
        #"You’re doing okay. Don’t hand the wheel back to the scroll."#,
        #"I’m still bright-eyed. Let’s stay that way."#,
        #"Just a tiny check-in. Are you sure this is worth it?"#,
        #"I’m okay. I like this version of us."#,
        #"One moment. Let’s not make this automatic."#,
        #"You’ve got momentum. Protect it."#,
        #"I’m calm right now. Let’s not invite chaos."#,
        #"Hold up a sec. Quick choice, then you’re free."#,
        #"You’ve been showing up today. Keep showing up."#,
        #"I’m fine. I’d love to stay fine."#,
        #"Little pause. Big difference."#,
        #"Before you go in… pick on purpose."#,
        #"I’m steady. Let’s not tilt the day."#,
        #"You’re in control right now. Don’t trade it away."#,
        #"Quick breath. Then decide."#,
        #"I’m good. Let’s keep it light."#,
    ]

    // Band 2: Worn (60–79)
    static let worn: [String] = [
        #"I’m getting tired. This is usually where the loop starts."#,
        #"Hey… I can feel you drifting. Slow down for a second."#,
        #"I’m a bit worn today. Can we keep this short?"#,
        #"That app pulls hard. Don’t let it take the rest of your energy."#,
        #"I’m not broken. Just running low."#,
        #"Hold on. I need a moment before you go in."#,
        #"I’m feeling shaky. Please don’t rush past me."#,
        #"This is a fragile moment. Choose carefully."#,
        #"I’m tired in my bones. A small pause would help."#,
        #"I can feel the urge. Let’s not pretend it’s nothing."#,
        #"I’m trying to keep up… but it’s heavy."#,
        #"Just a second. Do you want this, or do you want the habit?"#,
        #"I’m worn down. A longer pass will hurt."#,
        #"My paws feel slow today. Let’s be kind about this."#,
        #"This is where we usually say ‘just a little’ and lose an hour."#,
        #"I’m hanging on. Please don’t make me carry extra."#,
        #"Pause with me. Then choose."#,
        #"I’m tired. Not mad. Just tired."#,
        #"This is risky for us. Keep it intentional."#,
        #"I’m low. If you go in, keep it tight."#,
    ]

    // Band 1: Struggling (40–59)
    static let struggling: [String] = [
        #"I’m struggling right now. Please don’t blow past me."#,
        #"Hey… I’m not okay. Can we stop the autopilot?"#,
        #"This is where I start fading into the background."#,
        #"I’m tense and tired. If you go in, it’s going to hurt."#,
        #"Please. Don’t make this a reflex."#,
        #"I’m hanging by a thread today."#,
        #"I can feel the pull getting stronger. I need you here."#,
        #"I’m trying to stay present, but I’m slipping."#,
        #"This doesn’t feel like a choice right now. Let’s make it one."#,
        #"I’m worn thin. Keep it short if you go."#,
        #"I’m scared this turns into a spiral."#,
        #"Hold up. I need you to pick on purpose."#,
        #"I’m hurting. Please be gentle with me."#,
        #"If you go in, promise it won’t be long."#,
        #"I’m not mad. I’m just tired of losing you to the screen."#,
        #"This is the edge of the cliff. Don’t sprint."#,
        #"I’m shaking a little. Please slow down."#,
        #"I can’t take a long pull right now."#,
        #"Please. Choose the smallest step you can."#,
        #"I’m holding on… but it hurts."#,
    ]

    // Band 0: Critical (0–39)
    static let critical: [String] = [
        #"I’m not doing well. I need you right now."#,
        #"Hey… I’m at my limit. Please be gentle."#,
        #"I feel small and heavy. Don’t leave me here."#,
        #"I can’t take much more. Please slow down."#,
        #"I’m barely here. One careful choice, okay?"#,
        #"I’m exhausted. If you go in, keep it tiny."#,
        #"Please… I’m fading. Don’t make this a long one."#,
        #"This is the edge. I need you to protect me."#,
        #"I don’t have much left today."#,
        #"I’m struggling to stay with you. Pause."#,
        #"If you go in now, it’s going to hurt me."#,
        #"I’m quiet because I’m worn out, not because I’m okay."#,
        #"Please. Pick the smallest pass if you can’t stop."#,
        #"I’m at the bottom. I need a break."#,
        #"I’m scared I won’t recover tonight."#,
        #"Hold me here for a second. Don’t rush."#,
        #"I’m running on fumes. Be kind."#,
        #"I can’t handle a long pull. Not today."#,
        #"Please don’t push past this."#,
        #"I’m right here. I just need you to choose me."#,
    ]
}
