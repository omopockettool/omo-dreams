//
//  ContentView.swift
//  OMO Dreams
//
//  Created by Dennis Chicaiza A on 21/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dream.dream_date, order: .reverse) private var dreams: [Dream]
    
    @State private var showingAddDream = false
    @State private var dreamText = ""
    @State private var dreamTags = ""
    @State private var dreamDate = Date()
    @State private var editingDream: Dream? = nil
    
    // Computed property: all unique tags in lowercased, sorted
    var allTags: [String] {
        Set(dreams.flatMap { $0.dream_tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() } })
            .filter { !$0.isEmpty }
            .sorted()
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
                        ForEach(dreams) { dream in
                            Button(action: {
                                prepareForEditDream(dream)
                            }) {
                                DreamRowView(dream: dream)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .onDelete(perform: deleteDreams)
                    }
                }
            }
            .navigationTitle("OMO Dreams")
            .toolbar {
                if !dreams.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            prepareForNewDream()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddDream) {
                AddDreamSheet(
                    isPresented: $showingAddDream,
                    dreamText: $dreamText,
                    dreamTags: $dreamTags,
                    dreamDate: $dreamDate,
                    isEditing: editingDream != nil,
                    allTags: allTags,
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
        dreamTags = ""
        dreamDate = Calendar.current.startOfDay(for: Date())
        editingDream = nil
        showingAddDream = true
    }
    
    private func prepareForEditDream(_ dream: Dream) {
        dreamText = dream.dream_text
        dreamTags = dream.dream_tags
        dreamDate = dream.dream_date
        editingDream = dream
        showingAddDream = true
    }
    
    private func addDream() {
        withAnimation {
            let newDream = Dream(
                dream_date: dreamDate,
                dream_text: dreamText,
                dream_tags: dreamTags
            )
            modelContext.insert(newDream)
            dreamText = ""
            dreamTags = ""
        }
    }
    
    private func updateDream(_ dream: Dream) {
        withAnimation {
            dream.dream_date = dreamDate
            dream.dream_text = dreamText
            dream.dream_tags = dreamTags
        }
    }
    
    private func deleteDreams(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(dreams[index])
            }
        }
    }
}

struct DreamRowView: View {
    let dream: Dream
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dream.dream_date, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Text(dream.dream_date, format: Date.FormatStyle(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(dream.dream_text)
                .lineLimit(3)
                .font(.body)
            
            if !dream.dream_tags.isEmpty {
                HStack {
                    ForEach(dream.dream_tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddDreamSheet: View {
    @Binding var isPresented: Bool
    @Binding var dreamText: String
    @Binding var dreamTags: String
    @Binding var dreamDate: Date
    var isEditing: Bool = false
    var allTags: [String] = []
    var onSave: () -> Void
    
    @State private var selectedSuggestion: String? = nil
    @State private var showDatePicker: Bool = false
    
    var currentTagFragment: String {
        let parts = dreamTags.components(separatedBy: ",")
        return parts.last?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    }
    var tagSuggestions: [String] {
        guard !currentTagFragment.isEmpty else { return [] }
        return allTags.filter { $0.hasPrefix(currentTagFragment) && !dreamTags.lowercased().contains($0) }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Describe tu sueño")) {
                    TextEditor(text: $dreamText)
                        .frame(minHeight: 120, maxHeight: 200)
                        .padding(4)
                }
                Section(header: Text("Tags (separados por comas)")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Ejemplo: volar, agua, colores", text: $dreamTags)
                            .textInputAutocapitalization(.never)
                        if !tagSuggestions.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(tagSuggestions, id: \.self) { suggestion in
                                        Button(action: {
                                            autocompleteTag(suggestion)
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
                            .padding(.bottom, 24)
                        } else {
                            Spacer(minLength: 24)
                        }
                    }
                    .padding(.bottom, 8)
                }
                Section {
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
                    }
                    .buttonStyle(PlainButtonStyle())
                    if showDatePicker {
                        DatePicker("Selecciona la fecha", selection: $dreamDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding(.top, 4)
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
                        dreamTags = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave()
                        isPresented = false
                    }
                    .disabled(dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    private func autocompleteTag(_ tag: String) {
        var parts = dreamTags.components(separatedBy: ",")
        if parts.isEmpty {
            dreamTags = tag
        } else {
            parts[parts.count - 1] = " " + tag
            dreamTags = parts.joined(separator: ",").replacingOccurrences(of: ", ,", with: ", ")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dream.self, inMemory: true)
}
