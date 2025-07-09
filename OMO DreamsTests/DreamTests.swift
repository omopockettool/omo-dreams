import XCTest
@testable import OMO_Dreams
import SwiftData

final class DreamTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        modelContainer = try ModelContainer(for: [Dream.self, DreamPattern.self, Pattern.self], configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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
        let isLucid = true
        
        // When
        let dream = Dream(dream_date: date, dream_text: text, isLucid: isLucid)
        modelContext.insert(dream)
        
        // Then
        XCTAssertEqual(dream.dream_text, text)
        XCTAssertEqual(dream.isLucid, isLucid)
        XCTAssertEqual(dream.dream_date, date)
        XCTAssertFalse(dream.id.isEmpty)
    }
    
    func testDreamValidation() throws {
        // Given
        let emptyText = ""
        let validText = "Valid dream text"
        
        // When & Then
        let dreamWithEmptyText = Dream(dream_date: Date(), dream_text: emptyText, isLucid: false)
        XCTAssertTrue(dreamWithEmptyText.dream_text.isEmpty)
        
        let dreamWithValidText = Dream(dream_date: Date(), dream_text: validText, isLucid: true)
        XCTAssertFalse(dreamWithValidText.dream_text.isEmpty)
    }
    
    func testPatternCreation() throws {
        // Given
        let label = "flying"
        let category = "action"
        
        // When
        let pattern = Pattern(label: label, category: category)
        modelContext.insert(pattern)
        
        // Then
        XCTAssertEqual(pattern.label, label)
        XCTAssertEqual(pattern.category, category)
    }
    
    func testDreamPatternRelationship() throws {
        // Given
        let dream = Dream(dream_date: Date(), dream_text: "Test dream", isLucid: false)
        let pattern = Pattern(label: "flying", category: "action")
        let isRecognitionClue = true
        
        // When
        let dreamPattern = DreamPattern(dreamId: dream.id, pattern: pattern, isRecognitionClue: isRecognitionClue)
        dreamPattern.dream = dream
        dreamPattern.pattern = pattern
        
        modelContext.insert(dream)
        modelContext.insert(pattern)
        modelContext.insert(dreamPattern)
        
        // Then
        XCTAssertEqual(dreamPattern.dreamId, dream.id)
        XCTAssertEqual(dreamPattern.isRecognitionClue, isRecognitionClue)
        XCTAssertEqual(dreamPattern.dream, dream)
        XCTAssertEqual(dreamPattern.pattern, pattern)
    }
    
    func testPatternCategories() throws {
        // Test all pattern categories
        let categories = PatternCategory.allCases
        
        XCTAssertEqual(categories.count, 8)
        XCTAssertTrue(categories.contains(.action))
        XCTAssertTrue(categories.contains(.place))
        XCTAssertTrue(categories.contains(.character))
        XCTAssertTrue(categories.contains(.object))
        XCTAssertTrue(categories.contains(.emotion))
        XCTAssertTrue(categories.contains(.color))
        XCTAssertTrue(categories.contains(.sound))
        XCTAssertTrue(categories.contains(.other))
        
        // Test display names
        XCTAssertEqual(PatternCategory.action.displayName, "Action")
        XCTAssertEqual(PatternCategory.place.displayName, "Place")
        XCTAssertEqual(PatternCategory.character.displayName, "Character")
    }
} 