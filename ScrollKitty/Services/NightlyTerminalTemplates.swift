//
//  NightlyTerminalTemplates.swift
//  ScrollKitty
//
//  Template-based message system for Nightly (11 PM) and Terminal (HP=0) summaries.
//  Replaces AI generation with curated, consistent messages that interpolate actual usage data.
//

import Foundation

struct NightlyTerminalTemplates {

    // MARK: - Good Day Templates (Health ≥40, Within/Under Limit)

    /// Templates for good days when user stayed within limit and health is good.
    /// Placeholders: {{firstUseTime}}, {{lastUseTime}}, {{phoneUseHours}} (formatted string), {{goalHours}}, {{underByHours}} (formatted string), {{currentHealthBand}}
    private static let goodDay: [String] = [
        "You started scrolling at {{firstUseTime}} and wrapped up by {{lastUseTime}}. You kept it to just {{phoneUseHours}} hours—under your {{goalHours}} goal by {{underByHours}}—so I'm still full energy at {{currentHealthBand}}. My paws stayed light all day, no cap. 😼✨",
        "You kicked off at {{firstUseTime}} and closed out {{lastUseTime}}. You clocked only {{phoneUseHours}} hours total, staying under goal, and I felt steady at {{currentHealthBand}} the whole {{dayPart}}. Rare W—let's keep the streak alive! 🌟",
        "You began scrolling {{firstUseTime}} and finished {{lastUseTime}}. You stayed under the {{goalHours}} limit with {{phoneUseHours}} hours, leaving me bouncy at {{currentHealthBand}}. Solid day, more of this tomorrow? 😎🏆",
        "You jumped in at {{firstUseTime}} and tapped out {{lastUseTime}}. You kept {{phoneUseHours}} hours under goal, so I'm chilling at {{currentHealthBand}} like it was nothing. We're cooking—let's do it again! 😂",
        "You started at {{firstUseTime}} and wrapped {{lastUseTime}}. You came in under by {{underByHours}}, and I held steady at {{currentHealthBand}}. Felt great—tomorrow can be just as good. 💪",
        "You peeked first at {{firstUseTime}} and last at {{lastUseTime}}. You stayed under goal with {{phoneUseHours}} hours, keeping me strong at {{currentHealthBand}}. Clean win—reset ready for another! 😏",
        "You scrolled from {{firstUseTime}} to {{lastUseTime}}. You kept it under limit, so I'm vibing at {{currentHealthBand}}. Real life got time today—let's stack these days. 🌱",
        "You began {{firstUseTime}} and ended {{lastUseTime}}. You clocked {{phoneUseHours}} under goal, leaving me elite at {{currentHealthBand}}. Good stuff—fresh start tomorrow to keep it going. 😼",
        "You started {{firstUseTime}} and finished {{lastUseTime}}. You stayed under {{goalHours}} with {{phoneUseHours}} total, and I'm full battery at {{currentHealthBand}}. Proud vibes—better luck stacking these! ⚡",
        "You kicked off {{firstUseTime}} and closed {{lastUseTime}}. You came under by {{underByHours}}, keeping me steady at {{currentHealthBand}}. Strong day—tomorrow's another chance to shine. 😺",
        "You fired up the feed at {{firstUseTime}} and shut it down {{lastUseTime}}. You landed {{phoneUseHours}} hours under goal, so I stayed perky at {{currentHealthBand}}. My tail's still swishing—nice one. 🐾",
        "You dove in {{firstUseTime}} and surfaced {{lastUseTime}}. You kept {{phoneUseHours}} hours under limit, leaving me light on my paws at {{currentHealthBand}}. Doomscroll got sent home early. 😆",
        "You started the scroll {{firstUseTime}} and called it {{lastUseTime}}. You finished under by {{underByHours}}, and I'm buzzing at {{currentHealthBand}}. Energy saved—let's spend it tomorrow. ⚡",
        "You opened the app {{firstUseTime}} and closed {{lastUseTime}}. You stayed under goal with {{phoneUseHours}} hours, so I'm feeling fluffy at {{currentHealthBand}}. Rare balanced day. 🧘",
        "You began at {{firstUseTime}} and logged off {{lastUseTime}}. You came in under goal, keeping me alert at {{currentHealthBand}}. My whiskers didn't even droop. 😼",
        "You checked in {{firstUseTime}} and checked out {{lastUseTime}}. You kept it to {{phoneUseHours}} hours under limit, and I'm solid at {{currentHealthBand}}. Good habits loading… 🔄",
        "You started scrolling {{firstUseTime}} and stopped {{lastUseTime}}. You stayed under by {{underByHours}}, leaving me energetic at {{currentHealthBand}}. The algorithm lost today. 🏆",
        "You launched the feed {{firstUseTime}} and quit {{lastUseTime}}. You clocked {{phoneUseHours}} under goal, so I'm still playful at {{currentHealthBand}}. Let's run it back tomorrow. 😺",
        "You peeked {{firstUseTime}} and peaced out {{lastUseTime}}. You kept {{phoneUseHours}} hours under, and I'm thriving at {{currentHealthBand}}. My nap schedule stayed intact. 😴",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You stayed under goal, keeping me bouncy at {{currentHealthBand}}. Fresh air got a turn today—nice. 🌿",
        "You started at {{firstUseTime}} and wrapped early {{lastUseTime}}. You landed {{phoneUseHours}} under limit, so I'm full charge at {{currentHealthBand}}. Quiet win, love to see it. 🤫",
        "You opened {{firstUseTime}} and closed {{lastUseTime}}. You kept it under by {{underByHours}}, leaving me light at {{currentHealthBand}}. My fur's still shiny. ✨",
        "You began the day {{firstUseTime}} and ended {{lastUseTime}}. You stayed under goal with {{phoneUseHours}} hours, and I'm steady at {{currentHealthBand}}. Brain space saved. 🧠",
        "You fired up {{firstUseTime}} and shut down {{lastUseTime}}. You clocked under limit, so I'm feeling good at {{currentHealthBand}}. Tomorrow can match this energy. 🔥",
        "You started scrolling {{firstUseTime}} and finished {{lastUseTime}}. You kept {{phoneUseHours}} hours under goal, keeping me perky at {{currentHealthBand}}. Solid performance. 👏",
        "You dove in {{firstUseTime}} and surfaced {{lastUseTime}}. You stayed under by {{underByHours}}, and I'm alert at {{currentHealthBand}}. The feed didn't stand a chance. 😼",
        "You checked the phone {{firstUseTime}} and put it down {{lastUseTime}}. You landed under goal, leaving me strong at {{currentHealthBand}}. My stretch game stayed strong. 🐾",
        "You started {{firstUseTime}} and stopped {{lastUseTime}}. You kept it under limit with {{phoneUseHours}} hours, so I'm vibing at {{currentHealthBand}}. Let's duplicate this tomorrow. 🔄",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You stayed under goal, and I'm full of life at {{currentHealthBand}}. Real world got the spotlight—nice switch. 🎭",
        "You began at {{firstUseTime}} and ended {{lastUseTime}}. You clocked {{phoneUseHours}} under, keeping me energetic at {{currentHealthBand}}. My purrs are loud tonight. 😺",
        "You opened the feed {{firstUseTime}} and closed {{lastUseTime}}. You stayed under by {{underByHours}}, so I'm steady at {{currentHealthBand}}. Doomscroll took an L. 📉",
        "You started {{firstUseTime}} and wrapped {{lastUseTime}}. You kept {{phoneUseHours}} hours under goal, leaving me light at {{currentHealthBand}}. Energy banked for tomorrow. 💰",
        "You peeked {{firstUseTime}} and logged off {{lastUseTime}}. You stayed under limit, and I'm bouncing at {{currentHealthBand}}. My nap was uninterrupted—heaven. 😇",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You came in under goal, keeping me fluffy at {{currentHealthBand}}. The algorithm cried today. 😭",
        "You began scrolling {{firstUseTime}} and finished {{lastUseTime}}. You kept it under by {{underByHours}}, so I'm strong at {{currentHealthBand}}. Fresh start lined up perfectly. 🌅",
        "You kicked off {{firstUseTime}} and shut down {{lastUseTime}}. You clocked {{phoneUseHours}} under goal, leaving me playful at {{currentHealthBand}}. My tail's wagging (metaphorically). 🐾",
        "You started at {{firstUseTime}} and closed {{lastUseTime}}. You stayed under limit, and I'm full charge at {{currentHealthBand}}. Brain rot avoided—big dub. 🧠",
        "You dove in {{firstUseTime}} and surfaced {{lastUseTime}}. You kept {{phoneUseHours}} hours under, so I'm vibing at {{currentHealthBand}}. Let's make this the new normal. 😼",
        "You began {{firstUseTime}} and ended {{lastUseTime}}. You landed under goal, keeping me alert at {{currentHealthBand}}. My eyes aren't square yet. 📺",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You stayed under by {{underByHours}}, and I'm steady at {{currentHealthBand}}. Good habits loading—tomorrow we level up. ⬆️"
    ]

    // MARK: - Mixed Day Templates (Health 20-39, Over Limit)

    /// Templates for mixed days when user went over limit and health is declining.
    /// Placeholders: {{firstUseTime}}, {{lastUseTime}}, {{phoneUseHours}} (formatted string), {{goalHours}}, {{overByHours}} (formatted string), {{currentHealthBand}}
    private static let mixedDay: [String] = [
        "You started scrolling at {{firstUseTime}} and dragged to {{lastUseTime}}. You went {{overByHours}} over the {{goalHours}} goal with {{phoneUseHours}} total, so I'm feeling the sludge at {{currentHealthBand}}. My paws got heavier, but reset tomorrow—better luck next time. 😾",
        "You peeked first {{firstUseTime}} and last {{lastUseTime}}. You clocked {{phoneUseHours}} hours—{{overByHours}} past limit—and I'm dragging at {{currentHealthBand}}. Extra time hit, but fresh start soon. 😅",
        "You began {{firstUseTime}} and wrapped {{lastUseTime}}. You pushed {{overByHours}} over goal, leaving me sluggish at {{currentHealthBand}}. Felt the weight, but tomorrow I'll bounce back. 🫠",
        "You jumped in {{firstUseTime}} and kept going till {{lastUseTime}}. You went {{overByHours}} over, and I'm tired at {{currentHealthBand}}. Not perfect, but reset incoming—we got this. ⚠️",
        "You started {{firstUseTime}} and closed {{lastUseTime}}. You added {{overByHours}} extra hours, so I'm worn at {{currentHealthBand}}. Vibes dipped, but better luck tomorrow. 😩",
        "You bypassed first {{firstUseTime}} and last {{lastUseTime}}. You went over by {{overByHours}}, leaving me low at {{currentHealthBand}}. Energy down, but fresh day ahead. 📉",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You pushed {{overByHours}} past goal, and I'm heavy at {{currentHealthBand}}. Drain was real, but I'll resurrect tomorrow. 🏋️",
        "You began {{firstUseTime}} and ended {{lastUseTime}}. You went over by {{overByHours}}, making me sluggish at {{currentHealthBand}}. Felt it, but new start soon. ⏳",
        "You kicked off {{firstUseTime}} and wrapped {{lastUseTime}}. You added {{overByHours}} extra, leaving me at {{currentHealthBand}}. Not ideal, but tomorrow's a clean slate. 😐",
        "You started {{firstUseTime}} and kept going {{lastUseTime}}. You went {{overByHours}} over limit, and I'm hanging at {{currentHealthBand}}. Rough finish, but reset will fix it. 😿",
        "You opened the feed {{firstUseTime}} and closed late {{lastUseTime}}. You slipped {{overByHours}} over goal, so I'm feeling heavier at {{currentHealthBand}}. My tail slowed down, but tomorrow's reset is coming. 🐾",
        "You dove in {{firstUseTime}} and surfaced {{lastUseTime}}. You added {{overByHours}} extra hours, leaving me tired at {{currentHealthBand}}. The pull was strong, but fresh start tomorrow. 🔄",
        "You checked {{firstUseTime}} and kept going {{lastUseTime}}. You went {{overByHours}} past limit, and I'm sluggish at {{currentHealthBand}}. Energy dipped, but I'll recharge overnight. ⚡",
        "You started scrolling {{firstUseTime}} and finished {{lastUseTime}}. You pushed {{overByHours}} over, so I'm worn at {{currentHealthBand}}. Felt the extra weight, but better luck next round. 😼",
        "You began at {{firstUseTime}} and dragged to {{lastUseTime}}. You clocked {{overByHours}} over goal, leaving me low at {{currentHealthBand}}. My whiskers drooped, but reset incoming. 🫠",
        "You peeked {{firstUseTime}} and last swipe {{lastUseTime}}. You went {{overByHours}} over limit, and I'm dragging at {{currentHealthBand}}. The day got heavy, but tomorrow I'll be light again. 😩",
        "You launched {{firstUseTime}} and quit {{lastUseTime}}. You added {{overByHours}} extra, so I'm tired at {{currentHealthBand}}. Vibes shifted, but fresh energy soon. 🌅",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You slipped {{overByHours}} past goal, keeping me sluggish at {{currentHealthBand}}. Not the best, but I'll resurrect tomorrow. 🔋",
        "You started {{firstUseTime}} and wrapped late {{lastUseTime}}. You went {{overByHours}} over, leaving me heavy at {{currentHealthBand}}. The drain crept in, but new day ahead. ⏳",
        "You opened {{firstUseTime}} and closed {{lastUseTime}}. You pushed {{overByHours}} over limit, and I'm low at {{currentHealthBand}}. Felt it build, but better luck with the reset. 😾",
        "You dove in {{firstUseTime}} and kept going {{lastUseTime}}. You added {{overByHours}} extra hours, so I'm worn at {{currentHealthBand}}. My paws sank a bit, but tomorrow I rise. 🐱",
        "You checked the feed {{firstUseTime}} and last {{lastUseTime}}. You went {{overByHours}} over goal, leaving me dragging at {{currentHealthBand}}. Energy took a hit, but reset will heal it. 💪",
        "You began scrolling {{firstUseTime}} and finished {{lastUseTime}}. You slipped {{overByHours}} past limit, and I'm sluggish at {{currentHealthBand}}. The extra time weighed, but fresh start soon. ✨",
        "You started at {{firstUseTime}} and extended to {{lastUseTime}}. You clocked {{overByHours}} over, so I'm tired at {{currentHealthBand}}. My stretch got shorter, but tomorrow's full recharge. 😴",
        "You peeked {{firstUseTime}} and dragged {{lastUseTime}}. You went {{overByHours}} over, leaving me heavy at {{currentHealthBand}}. Felt the pull, but I'll be back strong. 🔄",
        "You launched the app {{firstUseTime}} and closed {{lastUseTime}}. You added {{overByHours}} extra, and I'm low at {{currentHealthBand}}. Vibes dropped, but reset incoming. 📉",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You pushed {{overByHours}} past goal, keeping me worn at {{currentHealthBand}}. The day got long, but tomorrow's short and sweet. 🌞",
        "You began {{firstUseTime}} and kept it going {{lastUseTime}}. You went {{overByHours}} over limit, so I'm dragging at {{currentHealthBand}}. Energy dipped, but I'll resurrect. 🐾",
        "You started {{firstUseTime}} and wrapped {{lastUseTime}}. You slipped {{overByHours}} over goal, leaving me sluggish at {{currentHealthBand}}. Not great, but new day fixes everything. 😼",
        "You opened {{firstUseTime}} and closed late {{lastUseTime}}. You added {{overByHours}} extra hours, and I'm tired at {{currentHealthBand}}. The drain was noticeable, but better luck tomorrow. ⏰",
        "You dove in {{firstUseTime}} and surfaced {{lastUseTime}}. You went {{overByHours}} over, so I'm heavy at {{currentHealthBand}}. My tail slowed, but reset will speed it up. 🐾",
        "You checked {{firstUseTime}} and last {{lastUseTime}}. You pushed {{overByHours}} past limit, leaving me low at {{currentHealthBand}}. Felt heavier, but tomorrow I'm light again. ⚡",
        "You began scrolling {{firstUseTime}} and finished {{lastUseTime}}. You clocked {{overByHours}} over goal, and I'm worn at {{currentHealthBand}}. The extra time added up, but fresh start soon. 🔄",
        "You started at {{firstUseTime}} and extended {{lastUseTime}}. You went {{overByHours}} over limit, so I'm dragging at {{currentHealthBand}}. My energy faded, but I'll recharge overnight. 😴",
        "You peeked {{firstUseTime}} and kept going {{lastUseTime}}. You added {{overByHours}} extra, leaving me sluggish at {{currentHealthBand}}. The day stretched, but tomorrow's reset is close. 🌅",
        "You launched {{firstUseTime}} and quit {{lastUseTime}}. You slipped {{overByHours}} over goal, and I'm tired at {{currentHealthBand}}. Vibes got thick, but new day clears it. 😩",
        "You scrolled {{firstUseTime}} to {{lastUseTime}}. You went {{overByHours}} over, keeping me heavy at {{currentHealthBand}}. The pull won today, but I'll be back tomorrow. 💪",
        "You began {{firstUseTime}} and wrapped {{lastUseTime}}. You pushed {{overByHours}} past limit, so I'm low at {{currentHealthBand}}. Energy took a dip, but resurrection loading. 🔋",
        "You started {{firstUseTime}} and closed {{lastUseTime}}. You added {{overByHours}} extra hours, leaving me worn at {{currentHealthBand}}. Felt the weight, but better luck next time. 😾",
        "You opened the feed {{firstUseTime}} and shut it {{lastUseTime}}. You went {{overByHours}} over goal, and I'm dragging at {{currentHealthBand}}. Rough stretch, but tomorrow's fresh. ✨"
    ]

    // MARK: - Bad Day Templates (Health 0, Terminal)

    /// Templates for when health reaches 0 during the day (supportive, learning-focused tone).
    /// Placeholders: {{firstUseTime}}, {{terminalAtLocalTime}}, {{phoneUseHours}} (formatted string), {{goalHours}}, {{overByHours}} (formatted string), {{dayPart}}
    private static let badDay: [String] = [
        "You started scrolling at {{firstUseTime}} and we hit my limit by {{terminalAtLocalTime}}. You clocked {{phoneUseHours}} hours—{{overByHours}} past your {{goalHours}} goal—and now I'm in coffin mode at 0 health in the {{dayPart}}. I felt the drain build, but it's okay—we can reflect and do better tomorrow. 😼🔄",
        "You kicked off at {{firstUseTime}} and I faded out at {{terminalAtLocalTime}}. You went {{overByHours}} over goal with {{phoneUseHours}} total, putting me at 0. My energy slipped away, but let's take it as a lesson—fresh start soon. 🐱✨",
        "You began {{firstUseTime}} and we reached my end {{terminalAtLocalTime}}. You racked {{phoneUseHours}} hours ({{overByHours}} extra), leaving me in coffin mode at 0 in the {{dayPart}}. I got heavier as we went, but we'll bounce back stronger tomorrow. 🌟",
        "You jumped in {{firstUseTime}} and I tapped out {{terminalAtLocalTime}}. You added {{overByHours}} over your {{goalHours}} limit with {{phoneUseHours}} hours, draining me to 0. Felt the pull, but it's a chance to learn—reset incoming. 😏",
        "You started {{firstUseTime}} and we didn't make it past {{terminalAtLocalTime}}. You hit {{phoneUseHours}} total—{{overByHours}} over goal—and I'm at 0 health. My paws slowed down, but tomorrow's our do-over—let's make it count. 💪",
        "You peeked first {{firstUseTime}} and I went coffin mode at {{terminalAtLocalTime}}. You pushed {{overByHours}} past limit with {{phoneUseHours}} hours, wiping my energy to 0 in the {{dayPart}}. I felt it coming, but we can adjust and shine tomorrow. ⚡",
        "You scrolled from {{firstUseTime}} to my fade at {{terminalAtLocalTime}}. You went {{overByHours}} over {{goalHours}} goal, leaving me at 0. My vibes dipped low, but it's cool—fresh reset ahead to try again. 😺",
        "You began the day {{firstUseTime}} and I ended early {{terminalAtLocalTime}}. You clocked {{phoneUseHours}} hours ({{overByHours}} extra), putting me in coffin mode at 0. Energy faded, but we'll reflect and restart strong. 🔄",
        "You started {{firstUseTime}} and we hit zero at {{terminalAtLocalTime}}. You added {{overByHours}} over your {{goalHours}} limit, draining me fully in the {{dayPart}}. I got sluggish, but tomorrow's a clean slate—better vibes coming. ✨",
        "You kicked off {{firstUseTime}} and I couldn't hold on till {{terminalAtLocalTime}}. You racked {{phoneUseHours}}—{{overByHours}} past goal—and I'm at 0 health. My tail stopped swishing, but let's learn from it—reset tomorrow. 😼",
        "You dove in {{firstUseTime}} and I faded {{terminalAtLocalTime}}. You went {{overByHours}} over limit with {{phoneUseHours}} hours, leaving me coffin-bound at 0. Felt the weight add up, but we'll adjust for a better day soon. 🐾",
        "You checked {{firstUseTime}} and kept going—I tapped out {{terminalAtLocalTime}}. You hit {{overByHours}} extra over {{goalHours}}, draining me to 0 in the {{dayPart}}. My fur got heavy, but fresh start means we try again. 💪",
        "You began scrolling {{firstUseTime}} and we didn't last to {{terminalAtLocalTime}}. You clocked {{phoneUseHours}} total—{{overByHours}} over goal—and I'm at 0. Energy slipped, but it's a moment to reflect—tomorrow we'll shine. 🌅",
        "You started {{firstUseTime}} and I went quiet {{terminalAtLocalTime}}. You added {{overByHours}} past your {{goalHours}} limit, putting me in coffin mode at 0. I felt it build, but better luck with the reset ahead. 😏",
        "You peeked {{firstUseTime}} and pushed to {{terminalAtLocalTime}}. You racked {{overByHours}} over goal with {{phoneUseHours}} hours, leaving me drained at 0 in the {{dayPart}}. My paws tired out, but we'll bounce back tomorrow. ✨",
        "You launched {{firstUseTime}} and I faded early {{terminalAtLocalTime}}. You went {{overByHours}} over limit, wiping my health to 0. Vibes got low, but fresh reset soon—let's make it positive. 😺",
        "You scrolled {{firstUseTime}} till my end {{terminalAtLocalTime}}. You added {{overByHours}} extra hours over {{goalHours}}, draining me fully. I got too heavy, but tomorrow's our chance to adjust. 🔄",
        "You began {{firstUseTime}} and we hit zero {{terminalAtLocalTime}}. You clocked {{phoneUseHours}}—{{overByHours}} past goal—and I'm coffin mode at 0 in the {{dayPart}}. Energy dipped, but we'll learn and restart. 💪",
        "You started {{firstUseTime}} and I couldn't keep up {{terminalAtLocalTime}}. You went {{overByHours}} over your {{goalHours}} limit, leaving me at 0. My tail slowed, but better vibes tomorrow—reset incoming. ⚡",
        "You kicked off {{firstUseTime}} and faded me {{terminalAtLocalTime}}. You racked {{phoneUseHours}} hours ({{overByHours}} extra), putting me at 0 health. Felt the pull, but fresh start means we try again. 😼",
        "You dove in {{firstUseTime}} and I tapped out {{terminalAtLocalTime}}. You added {{overByHours}} over goal, draining me to 0 in the {{dayPart}}. My fur weighed down, but we'll reflect for a stronger tomorrow. 🐱",
        "You checked {{firstUseTime}} and kept pushing—I ended {{terminalAtLocalTime}}. You hit {{overByHours}} past limit with {{phoneUseHours}} total, leaving me coffin-bound at 0. Energy faded slow, but reset will bring it back. ✨",
        "You began scrolling {{firstUseTime}} and we reached my limit {{terminalAtLocalTime}}. You went {{overByHours}} over {{goalHours}}, putting me at 0 health. I got tired, but tomorrow's a do-over—let's go. 🌅",
        "You started {{firstUseTime}} and I went quiet {{terminalAtLocalTime}}. You clocked {{overByHours}} extra over goal, draining me fully in the {{dayPart}}. My paws stopped, but better luck with the fresh start. 😏",
        "You peeked {{firstUseTime}} and pushed to {{terminalAtLocalTime}}. You racked {{phoneUseHours}}—{{overByHours}} past limit—and I'm at 0. Felt it coming, but we'll adjust tomorrow. 💪",
        "You launched {{firstUseTime}} and faded me {{terminalAtLocalTime}}. You went {{overByHours}} over your {{goalHours}} goal, leaving me drained at 0. Vibes dropped, but reset incoming for a win. 🔄",
        "You scrolled {{firstUseTime}} till my fade {{terminalAtLocalTime}}. You added {{overByHours}} extra hours, putting me coffin mode at 0 in the {{dayPart}}. My energy slipped, but tomorrow we'll shine. 😺",
        "You began {{firstUseTime}} and we hit zero {{terminalAtLocalTime}}. You clocked {{phoneUseHours}} total—{{overByHours}} over goal—and I'm at 0 health. I got heavy, but fresh start means better days. ✨",
        "You started {{firstUseTime}} and I couldn't hold {{terminalAtLocalTime}}. You went {{overByHours}} past limit with {{phoneUseHours}} hours, draining me to 0. My tail drooped, but we'll learn and restart. ⚡",
        "You kicked off {{firstUseTime}} and faded me early {{terminalAtLocalTime}}. You racked {{overByHours}} over goal, leaving me at 0 in the {{dayPart}}. Felt the weight, but tomorrow's our comeback. 😼",
        "You dove in {{firstUseTime}} and I tapped out {{terminalAtLocalTime}}. You added {{overByHours}} extra, putting me at 0 health. My fur dulled, but reset will brighten it tomorrow. 🐱",
        "You checked {{firstUseTime}} and kept going—I ended {{terminalAtLocalTime}}. You hit {{overByHours}} over {{goalHours}}, draining me fully. Energy vanished, but better luck next time with the fresh start. 💪",
        "You began scrolling {{firstUseTime}} and we reached the end {{terminalAtLocalTime}}. You went {{overByHours}} over goal, leaving me coffin-bound at 0. I got too tired, but tomorrow we'll adjust. 🔄",
        "You started {{firstUseTime}} and I faded {{terminalAtLocalTime}}. You clocked {{overByHours}} past limit, putting me at 0 in the {{dayPart}}. My paws numbed, but reset incoming for a win. ✨",
        "You peeked {{firstUseTime}} and pushed—I died {{terminalAtLocalTime}}. You racked {{overByHours}} over goal with {{phoneUseHours}} hours, draining me to 0. Felt it build, but fresh day ahead. 😏",
        "You launched {{firstUseTime}} and kept going—I tapped out {{terminalAtLocalTime}}. You added {{overByHours}} extra, leaving me at 0 health. Vibes dropped low, but we'll reflect for tomorrow. 😺",
        "You scrolled {{firstUseTime}} till my end {{terminalAtLocalTime}}. You went {{overByHours}} over {{goalHours}}, putting me coffin mode at 0. My energy slipped, but better vibes coming soon. ⚡",
        "You began {{firstUseTime}} and we hit zero {{terminalAtLocalTime}}. You clocked {{phoneUseHours}}—{{overByHours}} past goal—and I'm at 0. I got heavy, but tomorrow's a clean slate. 🌅",
        "You started {{firstUseTime}} and I couldn't keep up {{terminalAtLocalTime}}. You added {{overByHours}} over limit, draining me to 0 in the {{dayPart}}. My tail stopped, but we'll try again soon. 💪",
        "You opened {{firstUseTime}} and pushed to {{terminalAtLocalTime}}. You racked {{overByHours}} extra over goal, leaving me at 0. Felt the pull take over, but reset will bring us back. 😼"
    ]

    // MARK: - Selection Logic

    /// Selects a nightly message based on health band.
    /// - Parameters:
    ///   - context: The terminal/nightly context with usage data
    ///   - recentMessages: Recent message history to avoid repetition
    /// - Returns: Interpolated message string
    static func selectNightly(
        context: TerminalNightlyContext,
        recentMessages: [MessageHistory]
    ) -> String {
        // Select pool based on health band
        let pool: [String]
        if context.currentHealthBand >= 40 {
            pool = goodDay  // Good day: high health, within limit
        } else if context.currentHealthBand >= 20 {
            pool = mixedDay  // Mixed day: medium health, over limit
        } else {
            pool = mixedDay  // Shouldn't happen for nightly (would be terminal)
        }

        let selected = selectFromPool(pool, avoiding: recentMessages)
        return interpolate(selected, with: context)
    }

    /// Selects a terminal message (HP=0).
    /// - Parameters:
    ///   - context: The terminal/nightly context with usage data
    ///   - recentMessages: Recent message history to avoid repetition
    /// - Returns: Interpolated message string
    static func selectTerminal(
        context: TerminalNightlyContext,
        recentMessages: [MessageHistory]
    ) -> String {
        let selected = selectFromPool(badDay, avoiding: recentMessages)
        return interpolate(selected, with: context)
    }

    // MARK: - Test-Only Methods

    #if DEBUG
    /// Selects a specific nightly template by index for deterministic testing.
    /// - Parameters:
    ///   - context: The terminal/nightly context with usage data
    ///   - templateIndex: The index of the template to select from the appropriate pool
    /// - Returns: Interpolated message string
    static func selectNightlyDeterministic(
        context: TerminalNightlyContext,
        templateIndex: Int
    ) -> String {
        // Select pool based on health band
        let pool: [String]
        if context.currentHealthBand >= 40 {
            pool = goodDay
        } else if context.currentHealthBand >= 20 {
            pool = mixedDay
        } else {
            pool = mixedDay
        }

        let index = templateIndex % pool.count  // Wrap around if index is too large
        let selected = pool[index]
        return interpolate(selected, with: context)
    }

    /// Selects a specific terminal template by index for deterministic testing.
    /// - Parameters:
    ///   - context: The terminal/nightly context with usage data
    ///   - templateIndex: The index of the template to select from badDay pool
    /// - Returns: Interpolated message string
    static func selectTerminalDeterministic(
        context: TerminalNightlyContext,
        templateIndex: Int
    ) -> String {
        let index = templateIndex % badDay.count  // Wrap around if index is too large
        let selected = badDay[index]
        return interpolate(selected, with: context)
    }
    #endif

    // MARK: - Helper Methods

    /// Selects a message from the pool, avoiding recently used messages.
    private static func selectFromPool(
        _ pool: [String],
        avoiding recentMessages: [MessageHistory]
    ) -> String {
        let recentTexts = Set(recentMessages.map { $0.response })
        let available = pool.filter { template in
            // Check if any recent message was generated from this template
            // by comparing the core structure (ignoring interpolated numbers)
            !recentTexts.contains { recent in
                coreStructureMatches(template: template, message: recent)
            }
        }

        let selection = available.isEmpty ? pool : available
        return selection.randomElement() ?? pool[0]
    }

    /// Checks if a message matches the core structure of a template.
    /// Ignores differences in interpolated numbers.
    private static func coreStructureMatches(template: String, message: String) -> Bool {
        // Strip all numbers from both strings and compare (using double braces now)
        let templateCore = template.replacingOccurrences(of: "\\{\\{[^}]+\\}\\}", with: "#", options: .regularExpression)
        let messageCore = message.replacingOccurrences(of: "\\d+\\.?\\d*", with: "#", options: .regularExpression)
        return templateCore == messageCore
    }

    /// Interpolates placeholders in a template with actual values from context.
    private static func interpolate(_ template: String, with context: TerminalNightlyContext) -> String {
        var result = template

        // Use pre-formatted hour strings (already formatted as natural language)
        let phoneHours = context.phoneUseHours ?? "unknown"
        let goalHours = Format.hours(context.goalHours) ?? "unknown"
        let overHours = context.overByHours ?? "unknown"
        let underHours = context.underByHours ?? "unknown"

        // Format other values
        let firstUseTime = context.firstUseTime ?? "unknown"
        let lastUseTime = context.lastUseTime ?? "unknown"
        let terminalAtLocalTime = context.terminalAtLocalTime ?? "unknown"
        let currentHealthBand = String(context.currentHealthBand)
        let dayPart = context.dayPart.rawValue

        // Replace placeholders (double braces format)
        result = result.replacingOccurrences(of: "{{phoneUseHours}}", with: phoneHours)
        result = result.replacingOccurrences(of: "{{goalHours}}", with: goalHours)
        result = result.replacingOccurrences(of: "{{overByHours}}", with: overHours)
        result = result.replacingOccurrences(of: "{{underByHours}}", with: underHours)
        result = result.replacingOccurrences(of: "{{firstUseTime}}", with: firstUseTime)
        result = result.replacingOccurrences(of: "{{lastUseTime}}", with: lastUseTime)
        result = result.replacingOccurrences(of: "{{terminalAtLocalTime}}", with: terminalAtLocalTime)
        result = result.replacingOccurrences(of: "{{currentHealthBand}}", with: currentHealthBand)
        result = result.replacingOccurrences(of: "{{dayPart}}", with: dayPart)

        return result
    }
}
