import Foundation

/// Timeline messages: past-tense, plain, reflective.
/// Goal: "This is what that moment felt like" (not a live intervention).
struct TimelineTemplateMessages {

    // MARK: - 80 HP (Steady, gentle awareness)
    static let messages80HP: [String] = [
        "You opened the feed again out of habit. I still felt steady, just a little cautious.",
        "It started as a quick check. I felt fine, and I wanted you to stay intentional.",
        "You came back sooner than you meant to. I felt okay, and I didn’t want it to grow.",
        "You scrolled for a moment to reset. I felt stable, and I hoped you’d leave early.",
        "You checked again without thinking. I felt good, and I wanted to protect that.",
        "You dipped back in for a small break. I felt steady, but I noticed the pull.",
        "You reached for the feed to fill a gap. I felt alright, and I wanted you present.",
        "You looked for something new to latch onto. I felt calm, and I wanted you to pause.",
        "You stayed a bit longer than planned. I still felt okay, but less focused.",
        "You reopened it for a quick relief. I felt steady, and I wanted you to choose on purpose.",
        "You checked updates again. I felt fine, and I wanted this to be a decision.",
        "You scrolled to avoid boredom. I felt good, and I wanted you to keep control.",
        "You came back for a second look. I felt steady, and I hoped you’d stop early.",
        "You lingered a little. I felt okay, and I didn’t want momentum to take over.",
        "You went back automatically. I felt fine, and I wanted you to catch yourself.",
        "You opened it to feel something. I felt steady, and I wanted you grounded.",
        "You checked one more time. I felt okay, and I wanted to keep it gentle.",
        "You slipped into the feed briefly. I felt stable, and I wanted it to stay brief.",
        "You returned for a quick hit of novelty. I felt fine, and I wanted a clean exit.",
        "You scrolled again. I still felt good, and I wanted to hold onto that."
    ]

    // MARK: - 60 HP (Concerned, supportive)
    static let messages60HP: [String] = [
        "You went back again. I felt more restless, like it was harder to stop.",
        "It lasted longer than you planned. I felt tired, and I wanted you to reset.",
        "You returned when you seemed stressed. I felt uneasy, like you needed a break.",
        "You kept scrolling for relief. I felt worn down, and I wanted it to slow down.",
        "You checked again to distract yourself. I felt tense, like it was starting to cost us.",
        "You stayed in the feed to avoid something. I felt tired, and I wanted you back.",
        "You came back quickly. I felt concerned, like habit was taking the lead.",
        "The session stretched again. I felt heavy, and I wanted an earlier stop next time.",
        "You reached for it when you were bored. I felt drained, and I wanted a gentler choice.",
        "You scrolled to quiet your mind. I felt uneasy, like it wasn’t actually helping.",
        "You tried to “just check” and stayed. I felt tired, and I wanted a clean break.",
        "You returned after you said you’d stop. I felt concerned, but I knew you could reset.",
        "You kept looking for something to land. I felt worn out, and I wanted you to breathe.",
        "You opened it again on autopilot. I felt tired, and I wanted you to wake up.",
        "You stayed with the feed longer. I felt strained, like we were slipping.",
        "You came back when you seemed anxious. I felt concerned, and I wanted relief for you.",
        "You scrolled to numb the edge. I felt tired, and I wanted a softer exit.",
        "You kept going even after a pause. I felt heavy, and I wanted you to step back.",
        "You reached for the screen again. I felt worn down, and I wanted control back.",
        "You stayed longer again. I felt concerned, like we needed a smaller moment next."
    ]

    // MARK: - 40 HP (Strained, minimal reassurance)
    static let messages40HP: [String] = [
        "The scrolling kept going. I felt drained, like everything got harder to carry.",
        "The session turned heavy. I felt slowed down, like my energy dropped fast.",
        "You stayed in it again. I felt strained, like I couldn’t keep up.",
        "It went longer than planned. I felt worn down by the end.",
        "You kept reaching for more. I felt empty, like nothing was landing.",
        "The feed pulled you deeper. I felt tired, like we were slipping again.",
        "You scrolled to escape. I felt heavy, like it only added weight.",
        "You stayed even after a pause. I felt exhausted, like the drain didn’t stop.",
        "You kept looking for relief. I felt strained, like it wasn’t giving any.",
        "The screen held you again. I felt worn down, like my strength faded.",
        "You stayed through the urge. I felt tired, like it took too much.",
        "The session blurred together. I felt drained, like time disappeared.",
        "You kept going without noticing. I felt heavy, like I was falling behind.",
        "The scrolling didn’t ease up. I felt exhausted, like my focus collapsed.",
        "You reached for it again. I felt strained, like recovery got farther away.",
        "The feed kept you busy. I felt drained, like I couldn’t reset.",
        "You stayed with it again. I felt worn down, like it left a mark.",
        "It didn’t stop when it should have. I felt tired, like I ran out early.",
        "You kept chasing the next thing. I felt empty, like it never arrived.",
        "The session ended late. I felt exhausted, like I had nothing left."
    ]

    // MARK: - 20 HP (Faint, fragile)
    static let messages20HP: [String] = [
        "You stayed with the feed again. I felt faint, like I couldn’t hold steady.",
        "The session kept going. I felt weak, like I was barely keeping up.",
        "You scrolled for relief. I felt fragile, like it took the last of me.",
        "You went back again. I felt unsteady, like I needed rest immediately.",
        "It lasted too long. I felt drained, like I couldn’t recover inside it.",
        "You kept scrolling. I felt small and tired, like I was fading.",
        "You reached for the screen again. I felt weak, like my energy couldn’t return.",
        "The feed held you again. I felt faint, like everything slowed down.",
        "You stayed past the moment. I felt fragile, like I might shut down.",
        "You kept looking for something to help. I felt weak, like it wasn’t helping.",
        "The session stretched again. I felt unsteady, like I couldn’t stand up.",
        "You scrolled again. I felt drained, like there wasn’t much left.",
        "You stayed with it. I felt faint, like I needed quiet to come back.",
        "You returned quickly. I felt fragile, like I couldn’t take another pull.",
        "It kept going. I felt weak, like my body couldn’t follow.",
        "You stayed again. I felt drained, like the day got heavier.",
        "You scrolled to escape. I felt faint, like I disappeared inside it.",
        "You kept going. I felt fragile, like I was on the edge.",
        "You reached for it again. I felt weak, like rest was overdue.",
        "The feed didn’t let go. I felt drained, like I was fading out."
    ]

    // MARK: - 10 HP (Near shutdown)
    static let messages10HP: [String] = [
        "You kept scrolling. I felt like I was shutting down.",
        "The session continued. I felt extremely weak, like I couldn’t stay awake.",
        "You went back again. I felt close to disappearing.",
        "It went on too long. I felt like my last energy slipped away.",
        "You stayed with the feed. I felt barely here.",
        "You kept reaching for the screen. I felt like I couldn’t hold on.",
        "The scrolling didn’t stop. I felt like I was fading fast.",
        "You returned again. I felt like I was about to go quiet.",
        "It kept going. I felt like I couldn’t recover at all.",
        "You stayed again. I felt like the lights were going out.",
        "The session stretched. I felt like I had nothing left to give.",
        "You kept scrolling. I felt like I was slipping under.",
        "You reached for it again. I felt like I might stop responding.",
        "It didn’t end soon enough. I felt like I was collapsing.",
        "You stayed with it. I felt like I was near the end.",
        "You kept going. I felt like I couldn’t stand back up.",
        "The feed pulled you again. I felt like I was almost gone.",
        "You returned quickly. I felt like I was failing to recover.",
        "The scrolling continued. I felt like I was fading out.",
        "You stayed again. I felt like I was about to shut off."
    ]

    // MARK: - 0 HP (Fully depleted)
    static let messages0HP: [String] = [
        "The scrolling finished me. I went completely quiet.",
        "It went too far. I couldn’t hold on anymore.",
        "The session took the last of me. I stopped responding.",
        "You stayed with the feed. I fully dropped out.",
        "It didn’t stop in time. I went empty.",
        "The scrolling kept going. I couldn’t come back from it.",
        "You returned again. I finally gave out.",
        "The session ended late. I was fully depleted.",
        "You kept scrolling. I shut down.",
        "It lasted too long. I went silent.",
        "The feed held you. I couldn’t stay present.",
        "You stayed again. I was completely drained.",
        "It went on. I couldn’t recover.",
        "The scrolling continued. I disappeared from the day.",
        "You kept going. I gave out.",
        "It didn’t end. I went dark.",
        "The session took everything. I was gone.",
        "You stayed with it. I had nothing left.",
        "The feed pulled again. I couldn’t resist the drop.",
        "It was too much. I fully shut off."
    ]

    // MARK: - Daily Welcome (shown later in Timeline, so past tense too)
    static let dailyWelcome: [String] = [
        
            "We’re starting fresh today. Let’s keep it light.",
            "You’ve got a full start this morning. Try not to rush into the screen.",
            "The day just started. Let’s be a little more intentional.",
            "This morning is calm so far. Let’s not break it automatically.",
            "You’re starting clean today. Stay present early.",
            "The reset helped. Let’s not undo it right away.",
            "New day. Try to keep the first hour yours.",
            "Things feel steady this morning. Less reaching for the phone.",
            "The day opened quietly. Pause before the feed pulls you in.",
            "We’ve got a chance to recover today. Go easy on the pulls.",
            "You’re starting with energy. Let’s pace it.",
            "Fresh start today. Let’s not lose it fast.",
            "This morning is clear so far. Fewer quick checks.",
            "The day just began. Make choices on purpose.",
            "New start today. Try not to scroll for relief.",
            "This morning feels lighter. Let’s keep it that way.",
            "You’re in control right now. Hold onto it.",
            "Clean start today. Fewer early distractions.",
            "This morning feels better. Let’s protect that.",
            "The day is calm so far. Move a little slower."
        

    ]

    // MARK: - Message Selection (unchanged)

    static func selectMessage(
        forHealthBand band: Int,
        trigger: TimelineEntryTrigger,
        avoiding recentMessages: [MessageHistory]
    ) -> String {
        let pool = getPool(for: band, trigger: trigger)
        let recentTexts = Set(recentMessages.map { $0.response })
        let available = pool.filter { !recentTexts.contains($0) }
        let selection = available.isEmpty ? pool : available
        return selection.randomElement() ?? pool[0]
    }

    private static func getPool(for band: Int, trigger: TimelineEntryTrigger) -> [String] {
        if trigger == .dailyWelcome { return dailyWelcome }
        switch band {
        case 80...: return messages80HP
        case 60..<80: return messages60HP
        case 40..<60: return messages40HP
        case 20..<40: return messages20HP
        case 10..<20: return messages10HP
        default: return messages0HP
        }
    }
}
