//
//  AIDebugLogger.swift
//  ScrollKitty
//
//  Debug logging for AI response generation
//

import Foundation

struct AIDebugLogEntry: Codable {
    let timestamp: Date
    let trigger: String
    let tone: String
    let healthBefore: Int?
    let healthAfter: Int?
    let promptSent: String
    let responseMessage: String?
    let responseEmoji: String?
    let responseTone: String?
    let error: String?
    let generationOptions: String
}

actor AIDebugLogger {
    static let shared = AIDebugLogger()

    private let maxEntries = 50
    private let logKey = "aiDebugLog"

    private init() {}

    func log(
        trigger: String,
        tone: String,
        healthBefore: Int?,
        healthAfter: Int?,
        prompt: String,
        responseMessage: String? = nil,
        responseEmoji: String? = nil,
        responseTone: String? = nil,
        error: String? = nil,
        options: String
    ) {
        // Console logging for debugging
        print("[AIDebug] ═══════════════════════════════════")
        print("[AIDebug] Trigger: \(trigger) | Tone: \(tone)")
        if let before = healthBefore, let after = healthAfter {
            print("[AIDebug] Health: \(before) → \(after)")
        }
        print("[AIDebug] Options: \(options)")

        if let error = error {
            print("[AIDebug] ❌ ERROR: \(error)")
        } else if let message = responseMessage {
            print("[AIDebug] ✅ Response: \(message)")
            if let emoji = responseEmoji {
                print("[AIDebug] Emoji: \(emoji)")
            }
            print("[AIDebug] Tone returned: \(responseTone ?? "unknown")")
        }
        print("[AIDebug] ═══════════════════════════════════")

        let entry = AIDebugLogEntry(
            timestamp: Date(),
            trigger: trigger,
            tone: tone,
            healthBefore: healthBefore,
            healthAfter: healthAfter,
            promptSent: prompt,
            responseMessage: responseMessage,
            responseEmoji: responseEmoji,
            responseTone: responseTone,
            error: error,
            generationOptions: options
        )

        var logs = loadLogs()
        logs.append(entry)

        // Keep only last N entries
        if logs.count > maxEntries {
            logs = Array(logs.suffix(maxEntries))
        }

        saveLogs(logs)
    }

    func loadLogs() -> [AIDebugLogEntry] {
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        guard let data = defaults?.data(forKey: logKey),
              let decoded = try? JSONDecoder().decode([AIDebugLogEntry].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveLogs(_ logs: [AIDebugLogEntry]) {
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        if let encoded = try? JSONEncoder().encode(logs) {
            defaults?.set(encoded, forKey: logKey)
        }
    }

    func clearLogs() {
        let defaults = UserDefaults(suiteName: "group.com.scrollkitty.app")
        defaults?.removeObject(forKey: logKey)
    }

    func exportLogsAsText() -> String {
        let logs = loadLogs()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var output = "═══════════════════════════════\n"
        output += "   ScrollKitty AI Debug Log\n"
        output += "═══════════════════════════════\n"
        output += "Exported: \(formatter.string(from: Date()))\n"
        output += "Total entries: \(logs.count)\n"

        // Summary stats
        let errors = logs.filter { $0.error != nil }.count
        let successes = logs.filter { $0.responseMessage != nil }.count
        output += "✅ Success: \(successes) | ❌ Errors: \(errors)\n"
        output += "═══════════════════════════════\n\n"

        for (index, entry) in logs.enumerated().reversed() {
            output += "┌─────────────────────────────┐\n"
            output += "│ Entry \(logs.count - index) of \(logs.count)\n"
            output += "├─────────────────────────────┤\n"
            output += "│ Time: \(formatter.string(from: entry.timestamp))\n"
            output += "│ Trigger: \(entry.trigger)\n"
            output += "│ Tone requested: \(entry.tone)\n"
            if let before = entry.healthBefore, let after = entry.healthAfter {
                output += "│ Health: \(before) → \(after)\n"
            }
            output += "│ Options: \(entry.generationOptions)\n"
            output += "├─────────────────────────────┤\n"

            if let error = entry.error {
                output += "│ ❌ ERROR:\n"
                output += "│ \(error)\n"
                output += "├─────────────────────────────┤\n"
                output += "│ PROMPT SENT:\n"
                // Show first 500 chars of prompt for errors
                let promptPreview = String(entry.promptSent.prefix(500))
                for line in promptPreview.split(separator: "\n") {
                    output += "│ \(line)\n"
                }
                if entry.promptSent.count > 500 {
                    output += "│ ... (truncated)\n"
                }
            } else if let message = entry.responseMessage {
                output += "│ ✅ SUCCESS:\n"
                output += "│ Tone returned: \(entry.responseTone ?? "unknown")\n"
                output += "│ Message: \(message)\n"
                if let emoji = entry.responseEmoji {
                    output += "│ Emoji: \(emoji)\n"
                }
            }

            output += "└─────────────────────────────┘\n\n"
        }

        return output
    }
}
