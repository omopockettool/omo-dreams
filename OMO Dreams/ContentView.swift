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
    
    @State private var showingAddDream = false
    @State private var dreamText = ""
    @State private var dreamPatterns = ""
    @State private var dreamDate = Date()
    @State private var editingDream: Dream? = nil
    
    // Computed property: all unique patterns in lowercased, sorted
    var allPatterns: [String] {
        Set(dreams.flatMap { $0.dream_patterns.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() } })
            .filter { !$0.isEmpty }
            .sorted()
    }
    
    // Agrupa los sueños por fecha (sin hora)
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
                    dreamPatterns: $dreamPatterns,
                    dreamDate: $dreamDate,
                    isEditing: editingDream != nil,
                    allPatterns: allPatterns,
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
        dreamPatterns = ""
        dreamDate = Calendar.current.startOfDay(for: Date())
        editingDream = nil
        showingAddDream = true
    }
    
    private func prepareForEditDream(_ dream: Dream) {
        dreamText = dream.dream_text
        dreamPatterns = dream.dream_patterns
        dreamDate = dream.dream_date
        editingDream = dream
        showingAddDream = true
    }
    
    private func addDream() {
        withAnimation {
            let newDream = Dream(
                dream_date: dreamDate,
                dream_text: dreamText,
                dream_patterns: dreamPatterns
            )
            modelContext.insert(newDream)
            dreamText = ""
            dreamPatterns = ""
        }
    }
    
    private func updateDream(_ dream: Dream) {
        withAnimation {
            dream.dream_date = dreamDate
            dream.dream_text = dreamText
            dream.dream_patterns = dreamPatterns
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
            Text(dream.dream_text)
                .lineLimit(8)
                .font(.body)
                .foregroundColor(Color(.systemGray))
                .frame(minHeight: 40, alignment: .top)
            
            if !dream.dream_patterns.isEmpty {
                let patterns = dream.dream_patterns.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(patterns.chunked(into: 4).enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { pattern in
                                Text(pattern)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.2))
                                    .foregroundColor(.purple)
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
}

struct AddDreamSheet: View {
    @Binding var isPresented: Bool
    @Binding var dreamText: String
    @Binding var dreamPatterns: String
    @Binding var dreamDate: Date
    var isEditing: Bool = false
    var allPatterns: [String] = []
    var onSave: () -> Void
    
    @State private var selectedSuggestion: String? = nil
    @State private var showDatePicker: Bool = false
    @FocusState private var focusedField: Field?
    @State private var patternInput: String = ""
    @State private var patternChips: [String] = []
    
    enum Field {
        case description
        case patterns
    }
    
    var currentPatternFragment: String {
        let parts = patternInput.components(separatedBy: ",")
        return parts.last?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    }
    var patternSuggestions: [String] {
        guard !currentPatternFragment.isEmpty else { return [] }
        return allPatterns.filter { $0.hasPrefix(currentPatternFragment) && !patternChips.contains($0) }
    }
    
    func addPatternFromInput() {
        let trimmedPattern = patternInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedPattern.isEmpty, !patternChips.contains(trimmedPattern) else { return }
        
        patternChips.append(trimmedPattern)
        patternInput = ""  // ✅ limpia el campo después de agregar
        dreamPatterns = patternChips.joined(separator: ", ")  // ✅ actualiza el campo sincronizado
    }
        
    func removePattern(_ pattern: String) {
        patternChips.removeAll { $0 == pattern }
        dreamPatterns = patternChips.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        // Sección: Describe tu sueño
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
                        
                        // Sección: Patrones
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
                                            addPatternFromInput()  // ✅ enter también agrega el patrón
                                        }
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                
                                // Autocomplete suggestions right below input
                                if !patternSuggestions.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(patternSuggestions, id: \.self) { suggestion in
                                                Button(action: {
                                                    patternInput = suggestion
                                                    addPatternFromInput()
                                                }) {
                                                    Text(suggestion)
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
                                
                                // Chips organizados en filas de 4
                                if !patternChips.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(Array(patternChips.chunked(into: 4).enumerated()), id: \.offset) { rowIndex, row in
                                            HStack(spacing: 8) {
                                                ForEach(row, id: \.self) { pattern in
                                                    HStack(spacing: 4) {
                                                        Text(pattern)
                                                            .font(.caption)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.purple.opacity(0.2))
                                                            .foregroundColor(.purple)
                                                            .cornerRadius(8)
                                                        Button(action: { removePattern(pattern) }) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.caption)
                                                                .foregroundColor(.purple)
                                                        }
                                                    }
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .id("patternChips") // ID para ScrollViewReader
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Sección: Fecha
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
                .onChange(of: patternChips.count) { _, newCount in
                    // Scroll hacia los chips cuando se añade uno nuevo
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
                        Button("↑") {
                            focusedField = .description
                        }
                        .disabled(focusedField == .description)
                        
                        Button("↓") {
                            focusedField = .patterns
                        }
                        .disabled(focusedField == .patterns)
                        
                        Spacer()
                        
                        Button("Done") {
                            focusedField = nil
                        }
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
                        dreamPatterns = ""
                        patternChips = []
                        patternInput = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        addPatternFromInput()  // ✅ agrega lo que esté en el input antes de guardar
                        dreamPatterns = patternChips.joined(separator: ", ")
                        onSave()
                        isPresented = false
                    }
                }
            }
            .onAppear {
                // Inicializar patternChips desde dreamPatterns
                if !dreamPatterns.isEmpty {
                    let initial = dreamPatterns.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                    patternChips = initial
                } else {
                    patternChips = []
                }
            }
            .onChange(of: dreamPatterns) { _, newValue in
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dream.self, inMemory: true)
}

// Extensión para dividir arrays en chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }

        return stride(from: 0, to: count, by: size).map { startIndex in
            let endIndex = Swift.min(startIndex + size, count)
            return Array(self[startIndex..<endIndex])
        }
    }
}
