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
        let patterns = "test, dream, swift"
        
        // When
        let dream = Dream(dream_date: date, dream_text: text, dream_patterns: patterns)
        modelContext.insert(dream)
        
        // Then
        XCTAssertEqual(dream.dream_text, text)
        XCTAssertEqual(dream.dream_patterns, patterns)
        XCTAssertEqual(dream.dream_date, date)
    }
    
    func testDreamValidation() throws {
        // Given
        let emptyText = ""
        let validText = "Valid dream text"
        
        // When & Then
        let dreamWithEmptyText = Dream(dream_date: Date(), dream_text: emptyText, dream_patterns: "")
        XCTAssertTrue(dreamWithEmptyText.dream_text.isEmpty)
        
        let dreamWithValidText = Dream(dream_date: Date(), dream_text: validText, dream_patterns: "")
        XCTAssertFalse(dreamWithValidText.dream_text.isEmpty)
    }
    
    func testDreamPatternsParsing() throws {
        // Given
        let patterns = "flying, water, colors"
        let dream = Dream(dream_date: Date(), dream_text: "Test", dream_patterns: patterns)
        
        // When
        let parsedPatterns = dream.dream_patterns.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Then
        XCTAssertEqual(parsedPatterns.count, 3)
        XCTAssertEqual(parsedPatterns[0], "flying")
        XCTAssertEqual(parsedPatterns[1], "water")
        XCTAssertEqual(parsedPatterns[2], "colors")
    }
} 