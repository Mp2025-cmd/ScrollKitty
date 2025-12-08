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

        var output = "=== ScrollKitty AI Debug Log ===\n"
        output += "Exported: \(formatter.string(from: Date()))\n"
        output += "Total entries: \(logs.count)\n"
        output += "================================\n\n"

        for (index, entry) in logs.enumerated() {
            output += "--- Entry \(index + 1) ---\n"
            output += "Time: \(formatter.string(from: entry.timestamp))\n"
            output += "Trigger: \(entry.trigger)\n"
            output += "Tone: \(entry.tone)\n"
            if let before = entry.healthBefore, let after = entry.healthAfter {
                output += "Health: \(before) → \(after)\n"
            }
            output += "Options: \(entry.generationOptions)\n"
            output += "\n[PROMPT]\n\(entry.promptSent)\n"

            if let error = entry.error {
                output += "\n[ERROR]\n\(error)\n"
            } else if let message = entry.responseMessage {
                output += "\n[RESPONSE]\n"
                output += "Tone: \(entry.responseTone ?? "unknown")\n"
                output += "Message: \(message)\n"
                if let emoji = entry.responseEmoji {
                    output += "Emoji: \(emoji)\n"
                }
            }
            output += "\n"
        }

        return output
    }
}
