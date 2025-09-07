// AddAlbumView.swift
// Manual album entry form with validation

import SwiftUI

struct AddAlbumView: View {
    @State private var title = ""
    @State private var artist = ""
    @State private var year = ""
    @State private var genre = ""
    @State private var label = ""
    @State private var showingValidationError = false
    @FocusState private var focusedField: Field?

    let onAlbumAdded: (Album) -> Void
    @Environment(\.dismiss) private var dismiss

    enum Field: Hashable {
        case title, artist, year, genre, label
    }

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Album Information")) {
                    TextField("Album Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .artist
                        }

                    TextField("Artist", text: $artist)
                        .focused($focusedField, equals: .artist)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .year
                        }

                    TextField("Year (optional)", text: $year)
                        .focused($focusedField, equals: .year)
                        .keyboardType(.numberPad)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .genre
                        }

                    TextField("Genre (optional)", text: $genre)
                        .focused($focusedField, equals: .genre)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .label
                        }

                    TextField("Record Label (optional)", text: $label)
                        .focused($focusedField, equals: .label)
                        .submitLabel(.done)
                        .onSubmit {
                            if isFormValid {
                                saveAlbum()
                            }
                        }
                }

                Section {
                    Button("Save Album") {
                        saveAlbum()
                    }
                    .disabled(!isFormValid)
                }

                Section(footer: Text("Album title and artist are required fields.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Add Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAlbum()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            .alert("Invalid Album", isPresented: $showingValidationError) {
                Button("OK") { }
            } message: {
                Text("Please enter both album title and artist name.")
            }
            .onAppear {
                focusedField = .title
            }
        }
    }

    private func saveAlbum() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty && !trimmedArtist.isEmpty else {
            showingValidationError = true
            return
        }

        let yearInt = Int(year.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        let album = Album(
            title: trimmedTitle,
            artist: trimmedArtist,
            year: yearInt,
            genre: genre.trimmingCharacters(in: .whitespacesAndNewlines),
            label: label.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        onAlbumAdded(album)
    }
}

#Preview {
    AddAlbumView { album in
        print("Added: \(album.title) by \(album.artist)")
    }
}
