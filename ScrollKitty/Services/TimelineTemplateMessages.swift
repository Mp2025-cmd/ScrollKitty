//
//  TimelineTemplateMessages.swift
//  ScrollKitty
//
//  Fallback template messages for timeline when AI is unavailable
//

import Foundation

struct TimelineTemplateMessages {
    
    // MARK: - Main Template Generator
    
    nonisolated static func templateMessage(for trigger: TimelineEntryTrigger, tone: CatTone, context: TimelineAIContext) -> String {
        switch trigger {
        case .welcomeMessage:
            return "We're just starting our journey together. I'll jot little notes here as our day unfolds 😸"
            
        case .firstShieldOfDay:
            return firstShieldMessages(tone: tone)
            
        case .firstBypassOfDay:
            return firstBypassMessages(tone: tone)
            
        case .cluster:
            return clusterMessages(tone: tone)
            
        case .dailyLimitReached:
            return dailyLimitMessages(tone: tone, context: context)
            
        case .quietReturn:
            return quietReturnMessages(tone: tone, context: context)
            
        case .dailySummary:
            return dailySummaryMessages(tone: tone, context: context)
        }
    }
    
    // MARK: - First Shield of Day
    
    nonisolated private static func firstShieldMessages(tone: CatTone) -> String {
        switch tone {
        case .playful:
            return ["Morning! Ready to see how today goes? 🌤️",
                    "We're starting fresh today ✨",
                    "New day, new rhythm. Let's see what happens 🐾"].randomElement()!
            
        case .concerned:
            return ["Starting another day… let's try to keep it chill 🌥️",
                    "Here we go again. Hoping for a calmer vibe today",
                    "New day. Trying to stay optimistic here 🐾"].randomElement()!
            
        case .strained:
            return ["Another day… honestly feeling a bit worn already 😮‍💨",
                    "Starting today but I'm already kinda tired",
                    "Here we go… not sure how much I have left today"].randomElement()!
            
        case .faint:
            return ["Barely hanging on as we start… 🫠",
                    "Starting the day but I'm running on fumes",
                    "I'm here but… barely 😵‍💫"].randomElement()!
            
        case .dead:
            return "I couldn't make it… 🪦"
        }
    }
    
    // MARK: - First Bypass of Day
    
    private static func firstBypassMessages(tone: CatTone) -> String {
        switch tone {
        case .playful:
            return ["Okay, we pushed through once. All good 🐾",
                    "First one of the day. We're still vibing ✨",
                    "Alright, one down. Feeling fine still 😸"].randomElement()!
            
        case .concerned:
            return ["We went through… feeling it a bit 🌥️",
                    "First push of the day. Starting to feel the weight",
                    "Okay… that took something out of me already"].randomElement()!
            
        case .strained:
            return ["That one hit harder than usual… 😮‍💨",
                    "Already feeling drained from that",
                    "We pushed through but I'm feeling it heavily"].randomElement()!
            
        case .faint:
            return ["That… really took a lot out of me 🫠",
                    "Barely made it through that one",
                    "I'm fading fast after that… 😵‍💫"].randomElement()!
            
        case .dead:
            return "That was the last straw… 🪦"
        }
    }
    
    // MARK: - Cluster (3+ in 15 min)
    
    private static func clusterMessages(tone: CatTone) -> String {
        switch tone {
        case .playful:
            return ["Whoa, we're moving fast today 🌀",
                    "That was a quick burst… feeling the pace",
                    "Things are picking up speed here 🐾"].randomElement()!
            
        case .concerned:
            return ["This is getting intense… 🌪️",
                    "We're spiraling a bit here, not gonna lie",
                    "That was a lot all at once… 🌥️"].randomElement()!
            
        case .strained:
            return ["This is too much too fast… I'm struggling 😮‍💨",
                    "Can't keep up with this pace… feeling overwhelmed",
                    "Everything's blurring together… 🫠"].randomElement()!
            
        case .faint:
            return ["I can't… this is too much… 😵‍💫",
                    "Completely overwhelmed… barely holding on",
                    "Everything's spinning… I'm fading 🫠"].randomElement()!
            
        case .dead:
            return "That spiral was too much… 🪦"
        }
    }
    
    // MARK: - Daily Limit Reached
    
    private static func dailyLimitMessages(tone: CatTone, context: TimelineAIContext) -> String {
        switch tone {
        case .playful:
            return ["We hit what we planned for today ✨",
                    "That's the limit we set. Still feeling okay though 🐾",
                    "We reached today's mark. Not bad 😸"].randomElement()!
            
        case .concerned:
            return ["We hit the limit… and I'm definitely feeling it 🌥️",
                    "That's what we aimed for, but it took a toll",
                    "Reached the mark… feeling pretty drained"].randomElement()!
            
        case .strained:
            return ["We hit the limit and I'm really struggling now 😮‍💨",
                    "That was the goal but… I'm barely hanging on",
                    "Reached it, but at what cost… 🫠"].randomElement()!
            
        case .faint:
            return ["We hit the limit… I don't have much left 😵‍💫",
                    "That's the mark but I'm completely drained",
                    "Reached it… but I'm fading fast 🫠"].randomElement()!
            
        case .dead:
            return "Hit the limit… and it finished me 🪦"
        }
    }
    
    // MARK: - Quiet Return (4+ hours)
    
    private static func quietReturnMessages(tone: CatTone, context: TimelineAIContext) -> String {
        switch tone {
        case .playful:
            return ["We had a nice calm stretch there… felt pretty peaceful 🌤️",
                    "That was a good quiet moment. Feeling refreshed ✨",
                    "Nice break there. Good rhythm 🐾"].randomElement()!
            
        case .concerned:
            return ["Had some quiet time… helped a bit 🌥️",
                    "That break was nice while it lasted",
                    "We were calm for a while there… now we're back"].randomElement()!
            
        case .strained:
            return ["Had a quiet moment… but I'm still pretty worn 😮‍💨",
                    "That break helped a little, but I'm still struggling",
                    "We were quiet, but I'm still feeling drained 🫠"].randomElement()!
            
        case .faint:
            return ["Even after that break… I'm barely here 😵‍💫",
                    "That quiet time wasn't enough… still fading",
                    "Had a pause but… I'm still so tired 🫠"].randomElement()!
            
        case .dead:
            return "Too late for quiet now… 🪦"
        }
    }
    
    // MARK: - Daily Summary
    
    private static func dailySummaryMessages(tone: CatTone, context: TimelineAIContext) -> String {
        // Check if it was a quiet day (0-1 bypasses)
        let wasQuiet = context.eventCount <= 1
        
        if wasQuiet {
            switch tone {
            case .playful:
                return ["Today was pretty calm on my end. Thanks for giving us some space to breathe 🐾✨",
                        "Quiet day today. Felt nice and peaceful 🌤️",
                        "We had a chill day. Appreciate that 😸"].randomElement()!
                
            case .concerned:
                return ["Today was calmer than usual. I needed that 🌥️",
                        "Quiet day… gave me some time to recover",
                        "Not much happened today. Grateful for the break"].randomElement()!
                
            case .strained:
                return ["Today was quiet but… I'm still recovering from before 😮‍💨",
                        "Calm day, but I'm still feeling worn",
                        "Quiet today… but I'm still pretty drained 🫠"].randomElement()!
                
            case .faint:
                return ["Quiet day… but I'm still barely here 😵‍💫",
                        "Not much happened, but I'm still fading",
                        "Calm day… wish I felt better 🫠"].randomElement()!
                
            case .dead:
                return "Quiet day… but I'm already gone 🪦"
            }
        } else {
            // Active day
            switch tone {
            case .playful:
                return ["That's a wrap on today. We made it through ✨",
                        "Day's done. We handled it pretty well 🐾",
                        "Another day in the books. Feeling okay 😸"].randomElement()!
                
            case .concerned:
                return ["Today was a lot… glad it's over 🌥️",
                        "Made it through, but that took something out of me",
                        "Day's done… feeling pretty worn"].randomElement()!
                
            case .strained:
                return ["Barely made it through today… 😮‍💨",
                        "That was rough… really struggling now",
                        "Today took everything I had… 🫠"].randomElement()!
                
            case .faint:
                return ["I don't know how I made it… 😵‍💫",
                        "Today nearly finished me…",
                        "Barely survived that… 🫠"].randomElement()!
                
            case .dead:
                return "Today was too much… 🪦"
            }
        }
    }
}
