import XCTest
@testable import OMO_Dreams
import SwiftData

final class DreamTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        modelContainer = try ModelContainer(for: Dream.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }
    
    func testDreamCreation() throws {
        // Given
        let date = Date()
        let text = "Test dream text"
        let tags = "test, dream, swift"
        
        // When
        let dream = Dream(dream_date: date, dream_text: text, dream_tags: tags)
        modelContext.insert(dream)
        
        // Then
        XCTAssertEqual(dream.dream_text, text)
        XCTAssertEqual(dream.dream_tags, tags)
        XCTAssertEqual(dream.dream_date, date)
    }
    
    func testDreamValidation() throws {
        // Given
        let emptyText = ""
        let validText = "Valid dream text"
        
        // When & Then
        let dreamWithEmptyText = Dream(dream_date: Date(), dream_text: emptyText, dream_tags: "")
        XCTAssertTrue(dreamWithEmptyText.dream_text.isEmpty)
        
        let dreamWithValidText = Dream(dream_date: Date(), dream_text: validText, dream_tags: "")
        XCTAssertFalse(dreamWithValidText.dream_text.isEmpty)
    }
    
    func testDreamTagsParsing() throws {
        // Given
        let tags = "flying, water, colors"
        let dream = Dream(dream_date: Date(), dream_text: "Test", dream_tags: tags)
        
        // When
        let parsedTags = dream.dream_tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Then
        XCTAssertEqual(parsedTags.count, 3)
        XCTAssertEqual(parsedTags[0], "flying")
        XCTAssertEqual(parsedTags[1], "water")
        XCTAssertEqual(parsedTags[2], "colors")
    }
} 