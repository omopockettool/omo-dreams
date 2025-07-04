//
//  ContentView.swift
//  OMO Dreams
//
//  Created by Dennis Chicaiza A on 21/6/25.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.dream_date, order: .reverse) private var dreams: [Dream]
    @Query private var patterns: [Pattern]
    
    @State private var showingAddDream = false
    @State private var showingPatternManagement = false
    @State private var dreamText = ""
    @State private var dreamDate = Date()
    @State private var isLucid = false
    @State private var editingDream: Dream? = nil
    @State private var selectedPatterns: [PatternSelection] = []
    
    // Computed property: all unique patterns sorted by label
    var allPatterns: [Pattern] {
        patterns.sorted { $0.label < $1.label }
    }
    
    // Group dreams by date (without time) with stable section identifiers
    var dreamsByDate: [(date: Date, dreams: [Dream], sectionId: String)] {
        let grouped = Dictionary(grouping: dreams) { dream in
            Calendar.current.startOfDay(for: dream.dream_date)
        }
        return grouped.map { (date: $0.key, dreams: $0.value, sectionId: DateFormatter.sectionFormatter.string(from: $0.key)) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationView {
            VStack {
                if dreams.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("Tu Diario de Sueños")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemGray))
                        
                        Text("Comienza a registrar tus sueños para descubrir patrones y lograr sueños lúcidos")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: {
                            prepareForNewDream()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Agregar Primer Sueño")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(dreamsByDate, id: \.sectionId) { (date, dreamsForDate, sectionId) in
                            Section(header: Text("\(date.formatted(date: .abbreviated, time: .omitted)) (\(dreamsForDate.count))")) {
                                ForEach(dreamsForDate, id: \.id) { dream in
                                    ZStack {
                                        // Invisible background to capture all taps
                                        Rectangle()
                                            .fill(Color.clear)
                                            .contentShape(Rectangle())
                                        
                                        DreamRowView(dream: dream)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                    }
                                    .onTapGesture {
                                        prepareForEditDream(dream)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color(.systemGray6))
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .leading).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                }
                                .onDelete { offsets in
                                    let dreamsToDelete = offsets.map { dreamsForDate[$0] }
                                    deleteDreams(dreamsToDelete)
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: dreamsByDate.map { $0.sectionId })
                }
            }
            .navigationTitle("OMO Dreams")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !dreams.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            prepareForNewDream()
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.purple)
                        }
                    }
                }
                
                // Pattern Management button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingPatternManagement = true
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.gray)
                    }
                }
                
                // Debug button to check database contents
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        debugDatabaseContents()
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                    }
                }
                
                // Clean orphaned patterns button (only show when there are patterns but no dreams)
                if dreams.isEmpty && !patterns.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            cleanOrphanedPatterns()
                        }) {
                            Image(systemName: "trash.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddDream) {
                AddDreamSheet(
                    isPresented: $showingAddDream,
                    dreamText: $dreamText,
                    dreamDate: $dreamDate,
                    isLucid: $isLucid,
                    selectedPatterns: $selectedPatterns,
                    allPatterns: allPatterns,
                    isEditing: editingDream != nil,
                    onSave: {
                        if let editingDream = editingDream {
                            updateDream(editingDream)
                        } else {
                            addDream()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingPatternManagement) {
                PatternManagementSheet(
                    isPresented: $showingPatternManagement,
                    patterns: patterns,
                    dreams: dreams,
                    modelContext: modelContext
                )
            }
        }
    }
    
    private func prepareForNewDream() {
        dreamText = ""
        dreamDate = Calendar.current.startOfDay(for: Date())
        isLucid = false
        selectedPatterns = []
        editingDream = nil
        showingAddDream = true
    }
    
    private func prepareForEditDream(_ dream: Dream) {
        dreamText = dream.dream_text
        dreamDate = dream.dream_date
        isLucid = dream.isLucid
        
        // Convert existing dream patterns to selection format
        selectedPatterns = dream.dreamPatterns.compactMap { dreamPattern in
            guard let pattern = dreamPattern.pattern else { return nil }
            return PatternSelection(
                pattern: pattern,
                isRecognitionClue: dreamPattern.isRecognitionClue
            )
        }
        
        editingDream = dream
        showingAddDream = true
    }
    
    private func addDream() {
        withAnimation(.easeInOut(duration: 0.4)) {
            let newDream = Dream(
                dream_date: dreamDate,
                dream_text: dreamText,
                isLucid: isLucid
            )
            modelContext.insert(newDream)
            
            // Add patterns
            for patternSelection in selectedPatterns {
                // Ensure the pattern is in the context before creating DreamPattern
                let pattern = patternSelection.pattern
                if !allPatterns.contains(where: { $0.label == pattern.label }) {
                    modelContext.insert(pattern)
                }
                
                let dreamPattern = DreamPattern(
                    dreamId: newDream.id,
                    pattern: pattern,
                    isRecognitionClue: patternSelection.isRecognitionClue
                )
                dreamPattern.dream = newDream
                modelContext.insert(dreamPattern)
            }
            
            dreamText = ""
            selectedPatterns = []
        }
    }
    
    private func updateDream(_ dream: Dream) {
        // First, update basic properties
        dream.dream_date = dreamDate
        dream.dream_text = dreamText
        dream.isLucid = isLucid
        
        // Store existing patterns to delete
        let existingPatterns = dream.dreamPatterns
        
        // Remove existing patterns from relationship first
        dream.dreamPatterns.removeAll()
        
        // Delete existing patterns from context
        for dreamPattern in existingPatterns {
            modelContext.delete(dreamPattern)
        }
        
        // Save the deletion changes immediately
        do {
            try modelContext.save()
        } catch {
            print("Error saving pattern deletions: \(error)")
        }
        
        // Add new patterns
        for patternSelection in selectedPatterns {
            // Ensure the pattern is in the context before creating DreamPattern
            let pattern = patternSelection.pattern
            if !allPatterns.contains(where: { $0.label == pattern.label }) {
                modelContext.insert(pattern)
            }
            
            let dreamPattern = DreamPattern(
                dreamId: dream.id,
                pattern: pattern,
                isRecognitionClue: patternSelection.isRecognitionClue
            )
            dreamPattern.dream = dream
            modelContext.insert(dreamPattern)
        }
        
        // Save the addition changes
        do {
            try modelContext.save()
        } catch {
            print("Error saving new patterns: \(error)")
        }
    }
    
    private func deleteDreams(_ dreamsToDelete: [Dream]) {
        withAnimation(.easeInOut(duration: 0.35)) {
            for dream in dreamsToDelete {
                modelContext.delete(dream)
            }
        }
    }
    
    private func debugDatabaseContents() {
        let separator = String(repeating: "=", count: 60)
        print("\n" + separator)
        print("🔍 DEBUG: DATABASE CONTENTS")
        print(separator)
        
        // Count dreams
        print("\n📖 DREAMS (\(dreams.count)):")
        for (index, dream) in dreams.enumerated() {
            print("  \(index + 1). [\(dream.dream_date.formatted(date: .abbreviated, time: .omitted))] \(dream.dream_text.prefix(50))...")
            print("     Lucid: \(dream.isLucid)")
            print("     DreamPatterns: \(dream.dreamPatterns.count)")
            for (dpIndex, dreamPattern) in dream.dreamPatterns.enumerated() {
                if let pattern = dreamPattern.pattern {
                    print("       \(dpIndex + 1). \(pattern.label) (\(pattern.category)) - Clue: \(dreamPattern.isRecognitionClue)")
                } else {
                    print("       \(dpIndex + 1). NULL PATTERN - Clue: \(dreamPattern.isRecognitionClue)")
                }
            }
        }
        
        // Count all patterns
        print("\n🏷️ ALL PATTERNS (\(patterns.count)):")
        for (index, pattern) in patterns.enumerated() {
            let usageCount = dreams.flatMap { $0.dreamPatterns }.compactMap { $0.pattern }.filter { $0.label == pattern.label }.count
            print("  \(index + 1). '\(pattern.label)' (\(pattern.category)) - Used in \(usageCount) dreams")
        }
        
        // Count all dream patterns (relationships)
        let allDreamPatterns = dreams.flatMap { $0.dreamPatterns }
        print("\n🔗 ALL DREAMPATTERNS (\(allDreamPatterns.count)):")
        for (index, dreamPattern) in allDreamPatterns.enumerated() {
            if let pattern = dreamPattern.pattern {
                print("  \(index + 1). DreamPattern: \(pattern.label) -> Dream: \(dreamPattern.dream?.dream_text.prefix(30) ?? "NULL")")
            } else {
                print("  \(index + 1). DreamPattern: NULL PATTERN -> Dream: \(dreamPattern.dream?.dream_text.prefix(30) ?? "NULL")")
            }
        }
        
        // Check for orphaned patterns
        let orphanedPatterns = patterns.filter { pattern in
            !dreams.flatMap { $0.dreamPatterns }.compactMap { $0.pattern }.contains { $0.label == pattern.label }
        }
        
        print("\n🚫 ORPHANED PATTERNS (\(orphanedPatterns.count)):")
        for (index, pattern) in orphanedPatterns.enumerated() {
            print("  \(index + 1). '\(pattern.label)' (\(pattern.category)) - NOT USED in any dream")
        }
        
        if !orphanedPatterns.isEmpty {
            print("\n💡 TIP: Use cleanOrphanedPatterns() to remove unused patterns")
        }
        
        print("\n" + separator)
        print("🔍 DEBUG: END OF DATABASE CONTENTS")
        print(separator + "\n")
    }
    
    private func cleanOrphanedPatterns() {
        let orphanedPatterns = patterns.filter { pattern in
            !dreams.flatMap { $0.dreamPatterns }.compactMap { $0.pattern }.contains { $0.label == pattern.label }
        }
        
        print("🧹 CLEANING \(orphanedPatterns.count) ORPHANED PATTERNS...")
        
        for pattern in orphanedPatterns {
            print("  Deleting: '\(pattern.label)' (\(pattern.category))")
            modelContext.delete(pattern)
        }
        
        do {
            try modelContext.save()
            print("✅ Successfully cleaned \(orphanedPatterns.count) orphaned patterns")
        } catch {
            print("❌ Error cleaning orphaned patterns: \(error)")
        }
    }
}

struct DreamRowView: View {
    let dream: Dream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dream.dream_text)
                    .lineLimit(8)
                    .font(.body)
                    .foregroundColor(Color(.systemGray))
                    .frame(minHeight: 40, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if dream.isLucid {
                    Image(systemName: "eye.fill")
                        .foregroundColor(.purple)
                        .font(.caption)
                }
            }
            
            if !dream.dreamPatterns.isEmpty {
                let patterns = dream.dreamPatterns.compactMap { $0.pattern }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(patterns.chunked(into: 4).enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 8) {
                            ForEach(Array(row.enumerated()), id: \.offset) { idx, pattern in
                                Text(pattern.label)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(categoryColor(for: pattern.category))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "action": return .blue
        case "place": return .green
        case "character": return .orange
        case "object": return .purple
        case "emotion": return .red
        case "color": return .pink
        case "sound": return .indigo
        default: return .gray
        }
    }
}

struct PatternSelection: Identifiable, Equatable {
    let id = UUID()
    let pattern: Pattern
    var isRecognitionClue: Bool
    
    static func == (lhs: PatternSelection, rhs: PatternSelection) -> Bool {
        lhs.pattern.label == rhs.pattern.label
    }
}

struct AddDreamSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @Binding var dreamText: String
    @Binding var dreamDate: Date
    @Binding var isLucid: Bool
    @Binding var selectedPatterns: [PatternSelection]
    var allPatterns: [Pattern]
    var isEditing: Bool = false
    var onSave: () -> Void
    
    @State private var showDatePicker: Bool = false
    @State private var patternInput: String = ""
    @State private var selectedCategory: PatternCategory = .other
    @State private var categoryEditorPattern: PatternSelection?
    @FocusState private var focusedField: Field?
    
    enum Field {
        case description
        case patterns
    }
    
    var patternSuggestions: [Pattern] {
        guard !patternInput.isEmpty else { return [] }
        return allPatterns.filter { pattern in
            pattern.label.lowercased().contains(patternInput.lowercased()) && 
            !selectedPatterns.contains(where: { $0.pattern.label == pattern.label })
        }
    }
    
    func addPatternFromInput() {
        let trimmedPattern = patternInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedPattern.isEmpty else { return }
        
        // Check if pattern already exists
        if let existingPattern = allPatterns.first(where: { $0.label.lowercased() == trimmedPattern }) {
            if !selectedPatterns.contains(where: { $0.pattern.label == existingPattern.label }) {
                selectedPatterns.append(PatternSelection(pattern: existingPattern, isRecognitionClue: false))
            }
        } else {
            // Create new pattern
            let newPattern = Pattern(label: trimmedPattern, category: selectedCategory.rawValue)
            // Don't insert into context yet - will be handled when saving the dream
            selectedPatterns.append(PatternSelection(pattern: newPattern, isRecognitionClue: false))
        }
        
        patternInput = ""
    }
        
    func removePattern(_ patternSelection: PatternSelection) {
        selectedPatterns.removeAll { $0.id == patternSelection.id }
    }
    
    func toggleRecognitionClue(_ patternSelection: PatternSelection) {
        if let index = selectedPatterns.firstIndex(where: { $0.id == patternSelection.id }) {
            selectedPatterns[index].isRecognitionClue.toggle()
        }
    }
    
    func openCategoryEditor(for patternSelection: PatternSelection) {
        categoryEditorPattern = patternSelection
    }
    
    func updatePatternCategory(_ patternSelection: PatternSelection, newCategory: PatternCategory) {
        if let index = selectedPatterns.firstIndex(where: { $0.id == patternSelection.id }) {
            // Check if this pattern already exists in the database
            if let existingPattern = allPatterns.first(where: { $0.label == patternSelection.pattern.label }) {
                // Update existing pattern in database
                existingPattern.category = newCategory.rawValue
                
                // Update the selected pattern with the existing pattern reference
                selectedPatterns[index] = PatternSelection(
                    pattern: existingPattern,
                    isRecognitionClue: patternSelection.isRecognitionClue
                )
            } else {
                // For new patterns, directly update the category of the existing pattern object
                // This maintains the object reference and works correctly with SwiftUI
                patternSelection.pattern.category = newCategory.rawValue
                
                // Force UI update by creating a new PatternSelection with the updated pattern
                selectedPatterns[index] = PatternSelection(
                    pattern: patternSelection.pattern,
                    isRecognitionClue: patternSelection.isRecognitionClue
                )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        // Dream Description Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Describe tu sueño")
                                .font(.headline)
                                .foregroundColor(Color(.systemGray))
                            
                            TextEditor(text: $dreamText)
                                .frame(minHeight: max(300, 0), maxHeight: max(400, 300))
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .description)
                        }
                        .padding(.horizontal)
                        
                        // Patterns Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Patrones")
                                .font(.headline)
                                .foregroundColor(Color(.systemGray))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    TextField("Añade un patrón", text: $patternInput)
                                        .textInputAutocapitalization(.never)
                                        .focused($focusedField, equals: .patterns)
                                        .onSubmit {
                                            focusedField = .patterns
                                            addPatternFromInput()
                                        }
                                    
                                    Picker("Categoría", selection: $selectedCategory) {
                                        ForEach(PatternCategory.allCases, id: \.self) { category in
                                            Text(category.displayName).tag(category)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(Color(.systemGray))
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                
                                // Autocomplete suggestions
                                if !patternSuggestions.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(patternSuggestions, id: \.label) { suggestion in
                                                Button(action: {
                                                    patternInput = suggestion.label
                                                    addPatternFromInput()
                                                }) {
                                                    Text(suggestion.label)
                                                        .font(.caption)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(Color.purple.opacity(0.2))
                                                        .foregroundColor(.purple)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                
                                // Selected patterns
                                if !selectedPatterns.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(Array(selectedPatterns.chunked(into: 4).enumerated()), id: \.offset) { rowIndex, row in
                                            HStack(spacing: 8) {
                                                ForEach(Array(row.enumerated()), id: \.offset) { idx, patternSelection in
                                                    HStack(spacing: 4) {
                                                        Text(patternSelection.pattern.label)
                                                            .font(.caption)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(categoryColor(for: patternSelection.pattern.category))
                                                            .foregroundColor(.white)
                                                            .cornerRadius(8)
                                                            .onLongPressGesture {
                                                                openCategoryEditor(for: patternSelection)
                                                            }
                                                        
                                                        Button(action: { removePattern(patternSelection) }) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.caption)
                                                                .foregroundColor(.red)
                                                        }
                                                    }
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .id("patternChips")
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Lucid Dream Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(Color(.systemGray))
                                Text("Sueño Lúcido")
                                    .font(.headline)
                                    .foregroundColor(Color(.systemGray))
                                Spacer()
                                Toggle("", isOn: $isLucid)
                                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Date Section
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: { showDatePicker.toggle() }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(.systemGray))
                                    Text("Fecha: " + dreamDate.formatted(date: .abbreviated, time: .omitted))
                                        .foregroundColor(Color(.systemGray))
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if showDatePicker {
                                DatePicker("Selecciona la fecha", selection: $dreamDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .onChange(of: selectedPatterns.count) { _, newCount in
                    if newCount > 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                proxy.scrollTo("patternChips", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button(action: {
                            focusedField = .description
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        .disabled(focusedField == .description)
                        
                        Button(action: {
                            focusedField = .patterns
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        .disabled(focusedField == .patterns)
                        
                        Spacer()
                        
                        Button("Done") {
                            focusedField = nil
                        }
                        .foregroundColor(.purple)
                        .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        isPresented = false
                        dreamText = ""
                        selectedPatterns = []
                        patternInput = ""
                    }
                    .foregroundColor(.purple)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(isEditing ? "Editar Sueño" : "Nuevo Sueño")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        addPatternFromInput()
                        onSave()
                        isPresented = false
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
                }
            }
            .sheet(item: $categoryEditorPattern) { patternSelection in
                CategoryEditorSheet(
                    isPresented: .constant(true),
                    patternSelection: patternSelection,
                    onCategorySelected: { newCategory in
                        updatePatternCategory(patternSelection, newCategory: newCategory)
                        categoryEditorPattern = nil
                    }
                )
            }

        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "action": return .blue
        case "place": return .green
        case "character": return .orange
        case "object": return .purple
        case "emotion": return .red
        case "color": return .pink
        case "sound": return .indigo
        default: return .gray
        }
    }
}

struct CategoryEditorSheet: View {
    @Binding var isPresented: Bool
    let patternSelection: PatternSelection
    let onCategorySelected: (PatternCategory) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancelar") {
                    dismiss()
                }
                .foregroundColor(.purple)
                
                Spacer()
                
                Text("Editar Categoría")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.systemGray))
                
                Spacer()
                
                // Invisible button for balance
                Button("Cancelar") {
                    dismiss()
                }
                .foregroundColor(.clear)
                .disabled(true)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Pattern info
            VStack(spacing: 12) {
                HStack {
                    Text("Patrón:")
                        .foregroundColor(.secondary)
                    Text(patternSelection.pattern.label)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(categoryColor(for: patternSelection.pattern.category))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text("Selecciona una nueva categoría:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Categories list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(PatternCategory.allCases, id: \.self) { category in
                        Button(action: {
                            onCategorySelected(category)
                            dismiss()
                        }) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(categoryColor(for: category.rawValue))
                                    .frame(width: 24, height: 24)
                                
                                Text(category.displayName)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if category.rawValue == patternSelection.pattern.category {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.title3)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if category != PatternCategory.allCases.last {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "action": return .blue
        case "place": return .green
        case "character": return .orange
        case "object": return .purple
        case "emotion": return .red
        case "color": return .pink
        case "sound": return .indigo
        default: return .gray
        }
    }
}

struct PatternManagementSheet: View {
    @Binding var isPresented: Bool
    let patterns: [Pattern]
    let dreams: [Dream]
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteAlert = false
    @State private var patternToDelete: Pattern?
    
    // Structure to group patterns by category
    struct CategoryGroup {
        let category: String
        let patterns: [Pattern]
    }
    
    // Computed property to group patterns by category
    private var groupedPatterns: [CategoryGroup] {
        let grouped = Dictionary(grouping: patterns) { $0.category }
        return grouped.map { CategoryGroup(category: $0.key, patterns: $0.value) }
            .sorted { categoryDisplayName(for: $0.category) < categoryDisplayName(for: $1.category) }
    }
    
    private func categoryDisplayName(for category: String) -> String {
        switch category {
        case "action": return "Acción"
        case "place": return "Lugar"
        case "character": return "Personaje"
        case "object": return "Objeto"
        case "emotion": return "Emoción"
        case "color": return "Color"
        case "sound": return "Sonido"
        case "other": return "Otro"
        default: return category.capitalized
        }
    }
    
    private func patternUsageCount(_ pattern: Pattern) -> Int {
        return dreams.flatMap { $0.dreamPatterns }
            .compactMap { $0.pattern }
            .filter { $0.label == pattern.label }
            .count
    }
    
    private func requestDeletePattern(_ pattern: Pattern) {
        let usageCount = patternUsageCount(pattern)
        if usageCount > 0 {
            // Show confirmation alert for patterns in use
            patternToDelete = pattern
            showingDeleteAlert = true
        } else {
            // Delete directly if not in use
            deletePatternConfirmed(pattern)
        }
    }
    
    private func deletePatternConfirmed(_ pattern: Pattern) {
        modelContext.delete(pattern)
        do {
            try modelContext.save()
        } catch {
            print("Error deleting pattern: \(error)")
        }
    }
    
    private func cleanOrphanedPatterns() {
        let orphanedPatterns = patterns.filter { pattern in
            patternUsageCount(pattern) == 0
        }
        
        for pattern in orphanedPatterns {
            modelContext.delete(pattern)
        }
        
        do {
            try modelContext.save()
            print("✅ Successfully cleaned \(orphanedPatterns.count) orphaned patterns")
        } catch {
            print("❌ Error cleaning orphaned patterns: \(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Text("Administrar Patrones")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemGray))
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.clear)
                    .disabled(true)
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Patterns list grouped by category
                List {
                    ForEach(groupedPatterns, id: \.category) { categoryGroup in
                        Section(header: 
                            HStack {
                                Circle()
                                    .fill(categoryColor(for: categoryGroup.category))
                                    .frame(width: 20, height: 20)
                                Text(categoryDisplayName(for: categoryGroup.category))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("(\(categoryGroup.patterns.count))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        ) {
                            ForEach(categoryGroup.patterns.sorted(by: { $0.label < $1.label }), id: \.label) { pattern in
                                HStack {
                                    Text(pattern.label)
                                        .font(.body)
                                        .padding(.leading, 8)
                                    
                                    Spacer()
                                    
                                    let usageCount = patternUsageCount(pattern)
                                    Text("Apariciones: \(usageCount)")
                                        .font(.caption)
                                        .foregroundColor(usageCount == 0 ? .orange : .secondary)
                                    
                                    Button(action: {
                                        requestDeletePattern(pattern)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Stats footer
                VStack(spacing: 8) {
                    HStack {
                        Text("Total: \(patterns.count) patrones")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Categorías: \(groupedPatterns.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    let orphanedCount = patterns.filter { patternUsageCount($0) == 0 }.count
                    if orphanedCount > 0 {
                        Text("Patrones sin usar: \(orphanedCount)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Clean button (only show if there are orphaned patterns)
                let orphanedPatterns = patterns.filter { patternUsageCount($0) == 0 }
                if !orphanedPatterns.isEmpty {
                    Button(action: {
                        cleanOrphanedPatterns()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Eliminar \(orphanedPatterns.count) patrones sin usar")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .alert("Confirmar eliminación", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) {
                patternToDelete = nil
            }
            Button("Eliminar", role: .destructive) {
                if let pattern = patternToDelete {
                    deletePatternConfirmed(pattern)
                }
                patternToDelete = nil
            }
        } message: {
            if let pattern = patternToDelete {
                let usageCount = patternUsageCount(pattern)
                Text("¿Seguro que quieres eliminar el patrón '\(pattern.label)'?\n\nEste patrón está asociado a \(usageCount) sueño\(usageCount == 1 ? "" : "s").")
            }
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "action": return .blue
        case "place": return .green
        case "character": return .orange
        case "object": return .purple
        case "emotion": return .red
        case "color": return .pink
        case "sound": return .indigo
        default: return .gray
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(for: [Dream.self, DreamPattern.self, Pattern.self], inMemory: true)
}

// Extension to split arrays into chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0, !isEmpty else { return [] }

        return stride(from: 0, to: count, by: size).map { startIndex in
            let endIndex = Swift.min(startIndex + size, count)
            return Array(self[startIndex..<endIndex])
        }
    }
}

// Extension for stable date formatting
extension DateFormatter {
    static let sectionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
