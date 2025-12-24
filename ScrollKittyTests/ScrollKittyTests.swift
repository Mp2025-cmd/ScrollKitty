//
//  ScrollKittyTests.swift
//  ScrollKittyTests
//
//  Created by Peter on 10/19/25.
//

import Testing
import Foundation
@testable import ScrollKitty

struct ScrollKittyTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func timelineEventDecodesStringUUIDId() throws {
        let json = """
        {
          "id": "D8D4D85D-6E2E-4E33-8A89-0B8E9C747B52",
          "timestamp": 0,
          "appName": "App",
          "healthBefore": 100,
          "healthAfter": 95,
          "cooldownStarted": 0,
          "eventType": "shieldBypassed",
          "message": null,
          "emoji": null,
          "trigger": null
        }
        """

        let data = try #require(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(TimelineEvent.self, from: data)
        #expect(decoded.healthAfter == 95)
    }
}
