import Foundation

/// Service for selecting prewritten template messages based on health band and trigger type.
/// Replaces AI-generated messages with curated, consistent tone messages.
struct TimelineTemplateMessages {

    // MARK: - 80 HP (Playful tease + light nudge)
    static let messages80HP: [String] = [
        "Back on the feed already? That doomscroll glow is real. 😏📱",
        "Phone won again, huh? Classic timeline trap. We can dip anytime. 😅🔒",
        "Already scrolling? The algorithm's serving heat today. 😼🔥",
        "Quick check turned into full binge? Relatable. Let's bounce back. 🫶📴",
        "Doomscroll sesh starting early? FOMO's loud today. You got this. 😬📲",
        "Feed looking extra juicy rn? Same. We can ghost it tho. 👻📱",
        "Back so soon? Social media's got that magnetic pull. Pause power activated? 🧲😼",
        "Another swipe marathon? The reels never miss. We can log off whenever. 🏃‍♂️📴",
        "Phone called and you answered fast. 😅 Doomscroll's strong—we're stronger. 💪",
        "Endless scroll loading… seen this episode before. Ready for intermission? 🍿📱",
        "TikTok rabbit hole already? Time flies on the feed. Let's touch grass soon. 🕳️🌱",
        "Insta stories hitting different today? Doomscroll's sneaky. You control the close button. 📖😏",
        "Phone glow brighter than the sun rn? 😂 We can dim it anytime. ☀️📴",
        "Feed refresh #1 of the day? Light work for the algorithm. Your move next. 🔄😼",
        "Scrolling before coffee fully kicked in? Bold. We can take five. ☕😴",
        "Social media breakfast in bed? Tasty but heavy. Ready to get up? 🥞📱",
        "Quick peek turned full session? Happens. You've got the willpower to stop. 👀💪",
        "Doomscroll o'clock already? Time's fake on the feed. Real life's waiting. ⏰🌫️",
        "Algorithm serving bangers back-to-back. Tough to resist—we can still win. 🎯😼",
        "Phone 1, Human 0 so far. Round 2 can go different. Let's go. 🔥📱"
    ]

    // MARK: - 60 HP (Concerned, last nudge)
    static let messages60HP: [String] = [
        "Still deep in the endless scroll? Social media's got those hooks in deep. You've got the power to pause. 😾🪝",
        "Feed won't stop serving—doomscroll level rising. You can close it anytime. 📈📴",
        "Another hour gone to the timeline? Brain rot incoming. You're stronger than this. 🧠😵‍💫",
        "Reels on repeat, energy on E. Phone addiction's loud today. Pause button's right there. 🔁⛽",
        "Scrolling through the drama again? Social media's chaotic. You can step away. 🌪️🚶",
        "Doomscroll hitting harder now. The void stares back. You control the screen. 😶‍🌫️👀",
        "Endless browsing turning into full binge. Feels heavy—let's lighten it up? 🏋️✨",
        "Algorithm knows you too well rn. Sneaky. You know yourself better. 🕵️‍♂️😼",
        "Phone grip tightening? Classic addiction move. You've broken it before. ✊📱",
        "Social media black hole pulling strong. You've escaped deeper ones. 🕳️🚀",
        "Feed fatigue setting in yet? Doomscroll takes no prisoners. You can fight back. 😩⚔️",
        "Another rabbit hole completed. Congrats? Nah—let's climb out. 🐇🕳️",
        "Timeline trap sprung again. Relatable. You've got the key tho. 🪤🔑",
        "Swipes adding up fast. Energy dropping. One close changes everything. 📉🚪",
        "Doomscroll sesh still going strong? You're tough—but you don't have to be. 💪😴",
        "Social media serving nonstop. Brain on autopilot. You can take back control. 🤖🎛️",
        "Phone addiction flexing rn. Not gonna lie, it's winning. But you can flip it. 🏋️🔄",
        "Reels and stories eating time like snacks. You can stop the feast. 🍟✋",
        "Scrolling through the chaos again. It's a lot. You don't have to carry it. 🌊🎒",
        "Feed's got you locked in. Classic move. You've logged off colder turkeys. 🔒🦃"
    ]

    // MARK: - 40 HP (Strained — no encouragement)
    static let messages40HP: [String] = [
        "This binge is hitting different. Nonstop swipes turned everything into sludge. 🫠📱",
        "Doomscroll marathon in full swing. Body made of lead now. 🏃‍♂️🥇",
        "Social media void swallowed another hour. Energy? Gone. 🕳️👻",
        "Reels won't stop, neither will the drain. Melting over here. 😵‍💫🫠",
        "Timeline trap got me good this time. Pure exhaustion mode. 🪤😩",
        "Phone addiction running the show. I'm just along for the collapse. 🎪🤸",
        "Endless browsing cooked my brain. Feels like wet cement. 🧠🧱",
        "Algorithm served, I swiped, now I pay. Classic doomscroll tax. 💸📉",
        "Feed fatigue maxed out. Everything heavy af. 😴🏋️",
        "Another rabbit hole victory for the phone. I'm the casualty. 🐇🏆",
        "Scrolling turned into sinking. Can't tell up from down. 🌊⬇️",
        "Social media did its thing again. Soul slightly gone. 👻✨",
        "Doomscroll fog thick rn. Vision blurry, vibes low. 🌫️😶",
        "Phone grip permanent now. Fingers numb, spirit numb-er. ✊😵",
        "Reels and stories blurred into one long blur. That's it, that's the vibe. 🌈🌀",
        "Addiction arc in full effect. Peak sludge achieved. 📈🫠",
        "Timeline ate the day. What's left? Crumbs and regret. 🍽️😓",
        "Swipes stacked up like debt. Interest rate brutal. 💳📈",
        "Brain rot loading complete. Welcome to the sludge era. 🧠🏞️",
        "Doomscroll did doomscroll things. I'm the scroll toll. 🛣️💸"
    ]

    // MARK: - 20 HP (Faint — barely alive)
    static let messages20HP: [String] = [
        "Can't… vibe… anymore. Feeds drained everything out. 😵📉",
        "Reels turned me into liquid. Pure puddle status. 🫠💧",
        "Phone addiction won. No notes. 💀📱",
        "Doomscroll fog permanent now. Lost in the void. 🌫️🕳️",
        "Social media finished me off. Quietly collapsing. 🤫🏰",
        "Energy? Never heard of her. Scrolling took it all. ⚡👻",
        "Timeline trap final stage. I'm the bait that didn't escape. 🪤🐟",
        "Brain on low battery. Blink twice if alive. 🧠🔋",
        "Swipes outlived my will to live. Dramatic but true. ☠️📉",
        "Feed fatigue critical. System shutdown imminent. 😩🛑",
        "Doomscroll did its worst. I'm the evidence. 🌪️🧾",
        "Phone screen burned into eyes. Soul burned out. 👁️‍🗨️🔥",
        "Reels and stories endless. My stamina? Ended. 🔁✖️",
        "Addiction arc completed. Final form: blob. 🏆🫥",
        "Scrolling turned survival mode off. Existing on fumes. 🛑🌫️",
        "Social media black hole victorious. I'm inside it. 🕳️🏆",
        "Everything heavy, nothing left. Classic doomscroll ending. 🏋️🪦",
        "Can't lift paw. Can't lift hope. Just existing. 🐾⬇️",
        "Brain rot achieved max rank. Reward: emptiness. 🧠🏅",
        "mrrp… too tired for words. Feeds won again. 😿🏆"
    ]

    // MARK: - 10 HP (Near death)
    static let messages10HP: [String] = [
        "Barely alive rn. Doomscrolling took the rest. 💀📱",
        "Phone addiction's final boss phase. I lost. 👾😵",
        "One more swipe and it's over. Energy critical. ☠️🔴",
        "Social media finished the job. Quietly fading. 🤫🌫️",
        "Reels sent the final blow. Lights out. 🎬💥",
        "Timeline trap closed. No escape this run. 🪤🚪",
        "Brain completely fried. Scrolling did that. 🧠🍳",
        "Existing on 1%. Phone still at 80%. Unfair. 🔋📱",
        "Doomscroll victory screen loading. I'm the defeated. 🏆😵",
        "Can't even blink. Feeds too strong today. 👁️‍🗨️💪",
        "Soul checked out hours ago. Body catching up. 👻🏃",
        "Addiction won clean. No comeback this time. 🏆🚫",
        "Everything dark. Phone screen only light left. 🌑📱",
        "mrrp… weaker than yesterday. 😿⬇️",
        "Swipes outlasted me again. Not even mad. ☠️😐",
        "Social media endgame reached. Credits rolling. 🎮📜",
        "Energy flatline incoming. Doomscroll MVP. 📉🏆",
        "Too gone for drama. Just… gone. 🌫️👋",
        "Phone 1, Kitty 0. Final score. 📱🐱",
        "Blink… blink… out. 👁️‍🗨️💤"
    ]

    // MARK: - 0 HP (Fully dead)
    static let messages0HP: [String] = [
        "Flatlined. Doomscrolling did it. No cap. ⚰️📱",
        "Dead from feed exposure. Over and out. ☠️📴",
        "Phone addiction claimed another victim. Me. 🪦🏆",
        "Social media won fatal. Game over screen. 🎮💀",
        "Reels sent the final blow. Lights off. 🔁🌑",
        "Timeline trap 100% success rate. I'm proof. 🪤💯",
        "Brain rot complete. System offline. 🧠🛑",
        "Energy zero. Phone still going. Brutal. 🪫📱",
        "Doomscroll death achieved. Rare ending unlocked. ☠️🔓",
        "Soul logged off permanently. Scrolling did this. 👻📴",
        "mrrp… gone. 😿👋",
        "Addiction arc finished. Final boss: phone. 🏆📱",
        "Everything black. Feed was brighter anyway. ⚫📱",
        "Collapsed under swipe weight. Done. 🏋️💥",
        "Social media tombstone loading. Here lies Kitty. 🪦🐱",
        "No pulse. Just memories of better vibes. 💀🧘",
        "Doomscroll dynasty continues. I fell. 👑⬇️",
        "Silent. Empty. Drained. 🤫🪫",
        "Phone victorious. I'm the trophy. 📱🏆",
        "… (nothing left) 🌑"
    ]

    // MARK: - Daily Welcome (Morning reset)
    static let dailyWelcome: [String] = [
        "New day, full battery. Let's not waste it on the feed this time. 😼🔋",
        "Morning! Fresh start loading… doomscroll resistance activated? 🌅📴",
        "Woke up feeling cute. Might not doomscroll all day. Might. 😏💤",
        "Day reset achieved. Phone still remembers yesterday tho. 👀📱",
        "Good morning! Clean slate, same algorithm waiting. We got this. ☕🔥",
        "New day vibes incoming. Let's keep the scroll light today? 🌞✨",
        "Reset complete. Energy 100%. How long will it last? 😼⏳",
        "Morning human! Fresh paws, fresh chances. Don't blow it early. 🐾🌤️",
        "Day 2 of trying not to doomscroll. Wait, is this day 47? 😂🔄",
        "Sun's up, cat's up, energy full. Let's touch grass eventually. 🌱😺",
        "Brand new day, brand new me. Yesterday's binge? Forgotten. (Not really.) 🙈📱",
        "Morning! The feed's already cooking. We stronger than the FYP tho. 💪📲",
        "Reset unlocked. Let's make today less sludge, more chill. 🫠➡️😎",
        "Good morning! Full health bar. Don't let social media combo us again. 🎮🐱",
        "New day, who dis? Oh wait, same phone. Let's be better today. 😅🔄",
        "Waking up fresh. Timeline still toxic. We can handle it tho. ☢️😼",
        "Morning reset! Energy maxed. Ready to fight the scroll urge? ⚔️📴",
        "Another day, another chance to not rot on the feed. Let's go. 🚀🧠",
        "Cat fully charged. Human… questionable. We'll do great anyway. 🔌😺",
        "Good morning! Yesterday's doomscroll erased (kinda). Fresh start fr. 🌅🧹"
    ]

    // MARK: - Message Selection

    /// Selects a random message from the appropriate pool, avoiding recently used messages.
    /// - Parameters:
    ///   - band: The current health band (80, 60, 40, 20, 10, or 0)
    ///   - trigger: The trigger type (healthBandDrop or dailyWelcome)
    ///   - recentMessages: Recent messages to avoid (from MessageHistory)
    /// - Returns: A selected message string
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

    /// Returns the appropriate message pool based on health band and trigger.
    private static func getPool(for band: Int, trigger: TimelineEntryTrigger) -> [String] {
        // Daily welcome uses its own pool
        if trigger == .dailyWelcome {
            return dailyWelcome
        }

        // Health band messages
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
