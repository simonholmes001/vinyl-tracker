import SwiftUI
import UIKit

struct ScannerView: View {
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: ScannerViewModel
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var year: String = ""
    @State private var genre: String = ""
    @State private var notes: String = ""
    @State private var label: String = ""
    @State private var selectedCollections: Set<UUID>
    @State private var duplicateCandidate: Album?
    @State private var duplicateAlertAlbum: Album?
    @State private var showValidationAlert = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var showingCameraPicker = false
    @State private var showingPhotoLibraryPicker = false

    let preselectedCollections: [UUID]
    let onDismiss: () -> Void

    init(viewModel: ScannerViewModel, preselectedCollections: [UUID], onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.preselectedCollections = preselectedCollections
        self.onDismiss = onDismiss
        _selectedCollections = State(initialValue: Set(preselectedCollections))
    }

    var body: some View {
        Form {
            captureSection

            if case .processing = viewModel.state {
                Section {
                    HStack {
                        ProgressView()
                        Text("Analyzing cover...")
                            .foregroundColor(.secondary)
                    }
                }
            }

            albumDetailsSection
            collectionsSection

            if let suggestion = currentSuggestion {
                recognitionSection(for: suggestion)
            }
        }
        .navigationTitle("Scan Album")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") { dismissView() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { saveAlbum() }
                    .disabled(!isFormValid)
            }
        }
        .sheet(isPresented: $showingCameraPicker) {
            ImagePicker(sourceType: .camera) { image in
                handleCaptured(image: image)
            } onError: { message in
                showError(message)
            }
        }
        .sheet(isPresented: $showingPhotoLibraryPicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                handleCaptured(image: image)
            } onError: { message in
                showError(message)
            }
        }
        .alert("Duplicate Album", isPresented: Binding(
            get: { duplicateAlertAlbum != nil },
            set: { newValue in if !newValue { duplicateAlertAlbum = nil } }
        )) {
            Button("Add to Collection") {
                if let duplicate = duplicateAlertAlbum {
                    libraryViewModel.addExistingAlbum(duplicate.id, to: Array(selectedCollections))
                }
                duplicateAlertAlbum = nil
                dismissView()
            }

            Button("Add Anyway") {
                duplicateAlertAlbum = nil
                addAlbum(allowDuplicates: true)
            }

            Button("Cancel", role: .cancel) {
                duplicateAlertAlbum = nil
            }
        } message: {
            if let duplicate = duplicateAlertAlbum {
                Text("\(duplicate.title) by \(duplicate.artist) exists in your library. Add it to the selected collections or keep both copies.")
            }
        }
        .alert("Missing Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please provide both a title and an artist.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onChange(of: viewModel.state, perform: handleStateChange)
    }

    private var currentSuggestion: AlbumRecognitionSuggestion? {
        if case let .suggestion(suggestion, _) = viewModel.state {
            return suggestion
        }
        return nil
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @ViewBuilder
    private var captureSection: some View {
        Section("Cover") {
            if let image = viewModel.capturedImage {
                VStack(alignment: .leading, spacing: 12) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)

                    Button("Retake Photo") {
                        showingCameraPicker = true
                    }
                    .buttonStyle(.bordered)

                    Button("Choose from Library") {
                        showingPhotoLibraryPicker = true
                    }
                    .buttonStyle(.borderless)
                }
            } else {
                VStack(spacing: 16) {
                    Button {
                        showingCameraPicker = true
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        showingPhotoLibraryPicker = true
                    } label: {
                        Label("Photo Library", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var albumDetailsSection: some View {
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

            TextEditor(text: $notes)
                .frame(minHeight: 80)
        }
    }

    @ViewBuilder
    private var collectionsSection: some View {
        Section("Add to Collections") {
            if libraryViewModel.collections.isEmpty {
                Text("No collections available. Create one from the Collections tab.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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

    private func recognitionSection(for suggestion: AlbumRecognitionSuggestion) -> some View {
        Section("Recognition") {
            if suggestion.confidence > 0 {
                HStack {
                    Text("Confidence")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.0f%%", suggestion.confidence * 100))
                }
            }

            if !suggestion.candidateLines.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Detected text")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    let identifiedLines = suggestion.candidateLines.enumerated().map { IdentifiedLine(id: $0.offset, value: $0.element) }
                    ForEach(identifiedLines) { item in
                        Text(item.value)
                            .font(.callout)
                    }
                }
                .padding(.vertical, 4)
            }

            if let duplicateCandidate {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Possible duplicate", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("\(duplicateCandidate.title) by \(duplicateCandidate.artist) is already in your library.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func handleCaptured(image: UIImage) {
        viewModel.processCapturedImage(image)
    }

    private func handleStateChange(_ state: ScannerViewModel.ScanState) {
        switch state {
        case .idle:
            break
        case .processing:
            duplicateCandidate = nil
        case .failure(let message):
            showError(message)
        case .suggestion(let suggestion, let duplicate):
            if title.isEmpty {
                title = suggestion.suggestedTitle
            }
            if artist.isEmpty {
                artist = suggestion.suggestedArtist
            }
            if notes.isEmpty {
                notes = suggestion.candidateLines.joined(separator: "\n")
            }
            duplicateCandidate = duplicate
            if let duplicate {
                let membership = libraryViewModel.collectionsContainingAlbum(duplicate).map { $0.id }
                selectedCollections.formUnion(membership)
            }
        }
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
        let image = viewModel.capturedImage
        let result = libraryViewModel.addAlbum(
            title: title,
            artist: artist,
            year: yearValue,
            genre: genre,
            notes: notes,
            label: label,
            image: image,
            collectionIDs: Array(selectedCollections),
            allowDuplicateInsertion: allowDuplicates
        )

        switch result {
        case .inserted:
            dismissView()
        case .duplicate(let existing):
            duplicateAlertAlbum = existing
        case .rejected:
            showValidationAlert = true
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }

    private func dismissView() {
        onDismiss()
        dismiss()
    }
}

private struct IdentifiedLine: Identifiable {
    let id: Int
    let value: String
}
