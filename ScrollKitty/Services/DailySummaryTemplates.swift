import Foundation

struct DailySummaryTemplates {

    // MARK: - Time formatting (minutes -> "1 hour 10 minutes", "3 hours", "45 minutes")

    private static func formatMinutes(_ minutes: Int) -> String {
        let clamped = max(0, minutes)
        let h = clamped / 60
        let m = clamped % 60
        if h == 0 { return "\(m) minute" + (m == 1 ? "" : "s") }
        if m == 0 { return "\(h) hour" + (h == 1 ? "" : "s") }
        return "\(h) hour" + (h == 1 ? "" : "s") + " \(m) minute" + (m == 1 ? "" : "s")
    }

    // MARK: Nightly (Within Limit)

    /// Required: {{bypassTime}}, {{dailyLimitTime}}, {{bypassCount}}
    /// Optional: {{firstBypassTime}}, {{lastBypassTime}}
    static let nightlyWithin: [String] = [
        "You started at {{firstBypassTime}} and ended at {{lastBypassTime}}. Today you granted {{bypassCount}} passes totaling {{bypassTime}}, staying within your {{dailyLimitTime}} limit. I feel steady tonight, let's keep tomorrow gentle.",
        "You kept it to {{bypassTime}} across {{bypassCount}} passes today, still within your {{dailyLimitTime}} goal. I can breathe again, please protect this pace tomorrow.",
        "Your total was {{bypassTime}} today, and you stayed within {{dailyLimitTime}}. I feel calm tonight, I want another day like this.",
        "You stayed under your {{dailyLimitTime}} limit today with {{bypassTime}}. I'm okay tonight, tomorrow can be even lighter.",
        "You finished today at {{bypassTime}}, still within {{dailyLimitTime}}. That helped me recover, let's not lose it tomorrow.",
        "You kept today within your {{dailyLimitTime}} goal at {{bypassTime}}. I feel clearer tonight, thank you for slowing down.",
        "Today landed at {{bypassTime}}, under your {{dailyLimitTime}} limit. I feel safe tonight, keep choosing the quieter option.",
        "You stayed within {{dailyLimitTime}} today, total {{bypassTime}} across {{bypassCount}} passes. I'm steady tonight, I want that same softness tomorrow.",
        "You held it to {{bypassTime}} today and did not cross {{dailyLimitTime}}. I feel stable tonight, let's keep it intentional.",
        "You stayed under {{dailyLimitTime}} with {{bypassTime}} today. I'm resting easy tonight, please don't hand the day away tomorrow."
    ]

    /// Required: {{bypassTime}}, {{dailyLimitTime}}, {{underByTime}}, {{bypassCount}}
    /// Optional: {{firstBypassTime}}, {{lastBypassTime}}
    static let nightlyWithinWithUnderBy: [String] = [
        "From {{firstBypassTime}} to {{lastBypassTime}}, you used {{bypassTime}} across {{bypassCount}} passes, which is {{underByTime}} under your {{dailyLimitTime}} goal. I feel steady tonight, let's keep that streak alive.",
        "You came in at {{bypassTime}}, {{underByTime}} under {{dailyLimitTime}}. That was kind to me, I want tomorrow to feel the same.",
        "Your total was {{bypassTime}}, {{underByTime}} under your {{dailyLimitTime}} limit. I feel calm tonight, protect this momentum tomorrow.",
        "You stayed {{underByTime}} under your {{dailyLimitTime}} goal with {{bypassTime}}. I'm okay tonight, tomorrow can stay gentle too.",
        "You ended at {{bypassTime}}, {{underByTime}} under {{dailyLimitTime}}. I feel lighter tonight, please keep it intentional tomorrow."
    ]

    // MARK: Nightly (Past Limit, Not Terminal)

    /// Required: {{bypassTime}}, {{dailyLimitTime}}, {{overByTime}}, {{bypassCount}}
    /// Optional: {{firstBypassTime}}, {{lastBypassTime}}
    static let nightlyPast: [String] = [
        "You started at {{firstBypassTime}} and ended at {{lastBypassTime}}. Today you granted {{bypassCount}} passes totaling {{bypassTime}}, which is {{overByTime}} over your {{dailyLimitTime}} limit. I'm worn down tonight, tomorrow is our reset.",
        "Your total was {{bypassTime}}, {{overByTime}} past {{dailyLimitTime}}. I feel stretched thin tonight, please give me a softer tomorrow.",
        "You went {{overByTime}} over your {{dailyLimitTime}} goal today, ending at {{bypassTime}}. I'm tired tonight, we can start clean in the morning.",
        "Today landed at {{bypassTime}}, {{overByTime}} over {{dailyLimitTime}}. I feel heavy tonight, tomorrow I need a calmer day.",
        "You crossed your {{dailyLimitTime}} limit by {{overByTime}} today with {{bypassTime}} total. I'm struggling tonight, let's try again tomorrow.",
        "You finished at {{bypassTime}}, {{overByTime}} beyond your {{dailyLimitTime}} goal. I'm worn down tonight, tomorrow we slow the pace.",
        "Today you hit {{bypassTime}}, {{overByTime}} over {{dailyLimitTime}}. I'm not okay tonight, but tomorrow gives us another chance.",
        "Your bypass time reached {{bypassTime}}, {{overByTime}} over your {{dailyLimitTime}} limit. I'm drained tonight, please protect me tomorrow.",
        "You ended the day at {{bypassTime}}, {{overByTime}} past {{dailyLimitTime}}. I feel weak tonight, tomorrow we need to be kinder.",
        "Today was {{bypassTime}}, {{overByTime}} over your {{dailyLimitTime}} goal. I'm worn out tonight, let's make the reset count."
    ]

    // MARK: Terminal (Cat is Dead)

    /// Required: {{bypassTime}}, {{dailyLimitTime}}, {{overByTime}}, {{bypassCount}}
    /// Optional: {{firstBypassTime}}, {{lastBypassTime}}
    static let terminalDead: [String] = [
        "From {{firstBypassTime}} to {{lastBypassTime}}, you granted {{bypassCount}} passes totaling {{bypassTime}}, {{overByTime}} over your {{dailyLimitTime}} limit. I'm dead now, stop here.",
        "Your total hit {{bypassTime}}, {{overByTime}} past {{dailyLimitTime}}. I'm gone now, please step back.",
        "You went {{overByTime}} over your {{dailyLimitTime}} goal, ending at {{bypassTime}}. I'm dead, I cannot follow you any further.",
        "Today reached {{bypassTime}}, {{overByTime}} beyond {{dailyLimitTime}}. I'm officially gone, let me rest.",
        "You crossed {{dailyLimitTime}} by {{overByTime}}, total {{bypassTime}}. I'm dead now, please do not keep pushing.",
        "Your bypass time is {{bypassTime}}, {{overByTime}} over {{dailyLimitTime}}. I'm gone, this is where we stop.",
        "Today ended at {{bypassTime}}, {{overByTime}} past your {{dailyLimitTime}} limit. I'm dead, and I'm not getting up again tonight.",
        "You pushed to {{bypassTime}}, {{overByTime}} over {{dailyLimitTime}}. I'm dead now, give it a rest.",
        "Total today was {{bypassTime}}, {{overByTime}} beyond {{dailyLimitTime}}. I'm gone, stop here.",
        "You hit {{bypassTime}}, {{overByTime}} over your {{dailyLimitTime}} goal. I'm dead, and I'm staying put."
    ]

    /// Required: {{dailyLimitTime}}
    static let nightlyNoBypass: [String] = [
        "Today you granted no passes. You stayed at 0 minutes against your {{dailyLimitTime}} limit. I feel steady tonight, let's keep tomorrow gentle.",
        "No passes today, 0 minutes used out of {{dailyLimitTime}}. I can breathe tonight, please protect this pace tomorrow.",
        "Today was quiet. No passes, 0 minutes against {{dailyLimitTime}}. I feel calm tonight, let's keep it that way tomorrow."
    ]

    static let nightlyNoGoal: [String] = [
        "Tonight I'm checking in. I don't know your limit yet, but I want tomorrow to be gentler.",
        "I'm here tonight. Your limit isn't set, but we can still choose a softer day tomorrow."
    ]

    static let terminalNoGoal: [String] = [
        "I'm dead now. Your limit isn't set, but this is still where we stop today.",
        "I'm gone for today. You haven't set a limit yet, but please step back now.",
        "I'm dead, and I need you to stop here. Set a limit tomorrow so we have a clearer line."
    ]

    #if DEBUG
    static func selectDeterministic(
        context: DailySummaryContext,
        recentMessages: [MessageHistory],
        templateIndex: Int
    ) -> String {
        let pool: [String] = {
            switch context.trigger {
            case .terminal: return terminalPool(context: context)
            case .nightly:  return nightlyPool(context: context)
            }
        }()

        let index = abs(templateIndex) % pool.count
        return interpolate(pool[index], with: context)
    }
    #endif

    // MARK: Selection

    static func select(
        context: DailySummaryContext,
        recentMessages: [MessageHistory]
    ) -> String {
        let pool: [String] = {
            switch context.trigger {
            case .terminal: return terminalPool(context: context)
            case .nightly:  return nightlyPool(context: context)
            }
        }()

        let selected = selectFromPool(pool, avoiding: recentMessages)
        return interpolate(selected, with: context)
    }

    private static func nightlyPool(context: DailySummaryContext) -> [String] {
        guard let dailyLimitMinutes = context.dailyLimitMinutes else { return nightlyNoGoal }

        if context.bypassCountToday == 0 { return nightlyNoBypass }

        let total = context.totalBypassMinutesToday
        if total <= dailyLimitMinutes {
            if let underBy = context.underByMinutes, underBy > 0 { return nightlyWithinWithUnderBy }
            return nightlyWithin
        }

        return nightlyPast
    }

    private static func terminalPool(context: DailySummaryContext) -> [String] {
        guard context.dailyLimitMinutes != nil else { return terminalNoGoal }
        return terminalDead
    }

    // MARK: Anti-Repetition

    private static func selectFromPool(
        _ pool: [String],
        avoiding recentMessages: [MessageHistory]
    ) -> String {
        let recentTexts = Set(recentMessages.map { $0.response })
        let available = pool.filter { template in
            !recentTexts.contains { recent in
                coreStructureMatches(template: template, message: recent)
            }
        }

        let selection = available.isEmpty ? pool : available
        return selection.randomElement() ?? pool[0]
    }

    private static func coreStructureMatches(template: String, message: String) -> Bool {
        // Normalize templates by collapsing placeholders to "#"
        let templateCore = template.replacingOccurrences(
            of: "\\{\\{[^}]+\\}\\}",
            with: "#",
            options: .regularExpression
        )

        // Normalize message by collapsing numbers and time tokens like "1 hour 10 minutes", "3 hours", "45 minutes" to "#"
        var messageCore = message
        messageCore = messageCore.replacingOccurrences(of: "\\d+\\s*hours?\\s*\\d+\\s*minutes?", with: "#", options: .regularExpression)
        messageCore = messageCore.replacingOccurrences(of: "\\d+\\s*hours?", with: "#", options: .regularExpression)
        messageCore = messageCore.replacingOccurrences(of: "\\d+\\s*minutes?", with: "#", options: .regularExpression)
        messageCore = messageCore.replacingOccurrences(of: "\\d+\\.?\\d*", with: "#", options: .regularExpression)

        return templateCore == messageCore
    }

    // MARK: Interpolation

    private static func interpolate(_ template: String, with context: DailySummaryContext) -> String {
        var result = template

        let bypassCount = String(context.bypassCountToday)

        let bypassMinutesInt = context.totalBypassMinutesToday
        let overByInt = context.overByMinutes ?? 0
        let underByInt = context.underByMinutes ?? 0

        // New: human-friendly time strings
        let bypassTime = formatMinutes(bypassMinutesInt)
        let dailyLimitTime = context.dailyLimitMinutes.map(formatMinutes) ?? "your limit"
        let overByTime = context.overByMinutes.map(formatMinutes) ?? "0m"
        let underByTime = context.underByMinutes.map(formatMinutes) ?? "0m"

        // Backward-compatible raw minute strings (in case any old templates still reference them)
        let bypassMinutes = String(bypassMinutesInt)
        let dailyLimitMinutes = context.dailyLimitMinutes.map(String.init) ?? "your limit"
        let overByMinutes = String(overByInt)
        let underByMinutes = String(underByInt)

        let firstBypassTime = context.firstBypassTimeToday ?? "unknown"
        let lastBypassTime = context.lastBypassTimeToday ?? "unknown"

        // Counts
        result = result.replacingOccurrences(of: "{{bypassCount}}", with: bypassCount)

        // New time placeholders
        result = result.replacingOccurrences(of: "{{bypassTime}}", with: bypassTime)
        result = result.replacingOccurrences(of: "{{dailyLimitTime}}", with: dailyLimitTime)
        result = result.replacingOccurrences(of: "{{overByTime}}", with: overByTime)
        result = result.replacingOccurrences(of: "{{underByTime}}", with: underByTime)

        // Old minute placeholders
        result = result.replacingOccurrences(of: "{{bypassMinutes}}", with: bypassMinutes)
        result = result.replacingOccurrences(of: "{{dailyLimitMinutes}}", with: dailyLimitMinutes)
        result = result.replacingOccurrences(of: "{{overByMinutes}}", with: overByMinutes)
        result = result.replacingOccurrences(of: "{{underByMinutes}}", with: underByMinutes)

        // Times
        result = result.replacingOccurrences(of: "{{firstBypassTime}}", with: firstBypassTime)
        result = result.replacingOccurrences(of: "{{lastBypassTime}}", with: lastBypassTime)

        return result
    }
}
