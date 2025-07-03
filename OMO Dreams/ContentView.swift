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
    @State private var dreamText = ""
    @State private var dreamDate = Date()
    @State private var isLucid = false
    @State private var editingDream: Dream? = nil
    @State private var selectedPatterns: [PatternSelection] = []
    
    // Computed property: all unique patterns sorted by label
    var allPatterns: [Pattern] {
        patterns.sorted { $0.label < $1.label }
    }
    
    // Group dreams by date (without time)
    var dreamsByDate: [(date: Date, dreams: [Dream])] {
        let grouped = Dictionary(grouping: dreams) { dream in
            Calendar.current.startOfDay(for: dream.dream_date)
        }
        return grouped.map { (date: $0.key, dreams: $0.value) }.sorted { $0.date > $1.date }
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
                        ForEach(dreamsByDate, id: \.date) { (date, dreamsForDate) in
                            Section(header: Text("\(date.formatted(date: .abbreviated, time: .omitted)) (\(dreamsForDate.count))")) {
                                ForEach(dreamsForDate) { dream in
                                    Button(action: {
                                        prepareForEditDream(dream)
                                    }) {
                                        DreamRowView(dream: dream)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .onDelete { offsets in
                                    let dreamsToDelete = offsets.map { dreamsForDate[$0] }
                                    deleteDreams(dreamsToDelete)
                                }
                            }
                        }
                    }
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
        withAnimation {
            let newDream = Dream(
                dream_date: dreamDate,
                dream_text: dreamText,
                isLucid: isLucid
            )
            modelContext.insert(newDream)
            
            // Add patterns
            for patternSelection in selectedPatterns {
                let dreamPattern = DreamPattern(
                    dreamId: newDream.id,
                    pattern: patternSelection.pattern,
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
        withAnimation {
            dream.dream_date = dreamDate
            dream.dream_text = dreamText
            dream.isLucid = isLucid
            
            // Remove existing patterns
            for dreamPattern in dream.dreamPatterns {
                modelContext.delete(dreamPattern)
            }
            
            // Add new patterns
            for patternSelection in selectedPatterns {
                let dreamPattern = DreamPattern(
                    dreamId: dream.id,
                    pattern: patternSelection.pattern,
                    isRecognitionClue: patternSelection.isRecognitionClue
                )
                dreamPattern.dream = dream
                modelContext.insert(dreamPattern)
            }
        }
    }
    
    private func deleteDreams(_ dreamsToDelete: [Dream]) {
        withAnimation {
            for dream in dreamsToDelete {
                modelContext.delete(dream)
            }
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
                
                Spacer()
                
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
                            ForEach(row, id: \.label) { pattern in
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
        .padding(.vertical, 0)
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
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        // Dream Description Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Describe tu sueño")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $dreamText)
                                .frame(minHeight: 300, maxHeight: 400)
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
                                .foregroundColor(.primary)
                            
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
                                    .accentColor(.purple)
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
                                                ForEach(row, id: \.id) { patternSelection in
                                                    HStack(spacing: 4) {
                                                        Text(patternSelection.pattern.label)
                                                            .font(.caption)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(categoryColor(for: patternSelection.pattern.category))
                                                            .foregroundColor(.white)
                                                            .cornerRadius(8)
                                                        
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
                                    .foregroundColor(.purple)
                                Text("Sueño Lúcido")
                                    .font(.headline)
                                    .foregroundColor(.primary)
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
                                        .foregroundColor(.purple)
                                    Text("Fecha: " + dreamDate.formatted(date: .abbreviated, time: .omitted))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("(cambiar)")
                                        .font(.caption)
                                        .foregroundColor(.purple)
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
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
                            Image(systemName: "chevron.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        .disabled(focusedField == .description)
                        
                        Button(action: {
                            focusedField = .patterns
                        }) {
                            Image(systemName: "chevron.down.circle.fill")
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
            .navigationTitle(isEditing ? "Editar Sueño" : "Nuevo Sueño")
            .navigationBarTitleDisplayMode(.inline)
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
        guard size > 0 else { return [] }

        return stride(from: 0, to: count, by: size).map { startIndex in
            let endIndex = Swift.min(startIndex + size, count)
            return Array(self[startIndex..<endIndex])
        }
    }
}
