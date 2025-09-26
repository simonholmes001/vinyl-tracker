import SwiftUI

struct AddAlbumView: View {
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var year: String = ""
    @State private var genre: String = ""
    @State private var notes: String = ""
    @State private var label: String = ""
    @State private var selectedCollections: Set<UUID>
    @State private var duplicateAlbum: Album?
    @State private var showValidationAlert = false

    let preselectedCollections: [UUID]
    let onDismiss: () -> Void

    init(preselectedCollections: [UUID], onDismiss: @escaping () -> Void) {
        self.preselectedCollections = preselectedCollections
        self.onDismiss = onDismiss
        _selectedCollections = State(initialValue: Set(preselectedCollections))
    }

    var body: some View {
        Form {
            Section("Album Details") {
                TextField("Title", text: $title)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)

                TextField("Artist", text: $artist)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)

                TextField("Year", text: $year)
                    .keyboardType(.numberPad)

                TextField("Genre", text: $genre)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)

                TextField("Label", text: $label)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
            }

            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 80)
            }

            Section("Add to Collections") {
                if libraryViewModel.collections.isEmpty {
                    Text("No collections yet. You can create collections from the Collections tab.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(libraryViewModel.collections) { collection in
                        Toggle(isOn: Binding(
                            get: { selectedCollections.contains(collection.id) },
                            set: { isOn in
                                if isOn {
                                    selectedCollections.insert(collection.id)
                                } else {
                                    selectedCollections.remove(collection.id)
                                }
                            }
                        )) {
                            VStack(alignment: .leading) {
                                Text(collection.name)
                                if !collection.detail.isEmpty {
                                    Text(collection.detail)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Add Album")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismissView()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveAlbum()
                }
                .disabled(!isFormValid)
            }
        }
        .alert("Duplicate Album", isPresented: Binding(
            get: { duplicateAlbum != nil },
            set: { newValue in if !newValue { duplicateAlbum = nil } }
        )) {
            Button("Add to Collection") {
                if let duplicate = duplicateAlbum {
                    libraryViewModel.addExistingAlbum(duplicate.id, to: Array(selectedCollections))
                }
                duplicateAlbum = nil
                dismissView()
            }

            Button("Add Anyway") {
                addAlbum(allowDuplicates: true)
            }

            Button("Cancel", role: .cancel) {
                duplicateAlbum = nil
            }
        } message: {
            if let duplicate = duplicateAlbum {
                Text("\(duplicate.title) by \(duplicate.artist) already exists. You can add it to the selected collections or add a duplicate entry.")
            }
        }
        .alert("Missing Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please provide both a title and an artist.")
        }
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveAlbum() {
        guard isFormValid else {
            showValidationAlert = true
            return
        }
        addAlbum(allowDuplicates: false)
    }

    private func addAlbum(allowDuplicates: Bool) {
        let yearValue = Int(year.trimmingCharacters(in: .whitespacesAndNewlines))
        let result = libraryViewModel.addAlbum(
            title: title,
            artist: artist,
            year: yearValue,
            genre: genre,
            notes: notes,
            label: label,
            image: nil,
            collectionIDs: Array(selectedCollections),
            allowDuplicateInsertion: allowDuplicates
        )

        switch result {
        case .inserted:
            dismissView()
        case .duplicate(let existing):
            duplicateAlbum = existing
        case .rejected:
            showValidationAlert = true
        }
    }

    private func dismissView() {
        onDismiss()
        dismiss()
    }
}
