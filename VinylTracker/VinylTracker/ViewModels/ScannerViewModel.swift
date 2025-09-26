import Foundation
import UIKit

@MainActor
final class ScannerViewModel: ObservableObject, Identifiable {
    let id = UUID()
    enum ScanState: Equatable {
        case idle
        case processing
        case suggestion(AlbumRecognitionSuggestion, duplicate: Album?)
        case failure(String)
    }

    @Published private(set) var state: ScanState = .idle
    @Published private(set) var capturedImage: UIImage?

    private let repository: CollectionRepository
    private let recognitionService: AlbumRecognitionService
    private var recognitionTask: Task<Void, Never>?

    init(
        repository: CollectionRepository,
        recognitionService: AlbumRecognitionService = AlbumRecognitionService()
    ) {
        self.repository = repository
        self.recognitionService = recognitionService
    }

    func processCapturedImage(_ image: UIImage) {
        recognitionTask?.cancel()
        capturedImage = image
        state = .processing

        recognitionTask = Task { [weak self] in
            guard let self else { return }
            do {
                let suggestion = try await recognitionService.analyse(image: image)
                let duplicate = repository.duplicate(forTitle: suggestion.suggestedTitle, artist: suggestion.suggestedArtist)
                self.state = .suggestion(suggestion, duplicate: duplicate)
            } catch {
                let recognitionError = (error as? AlbumRecognitionError)?.errorDescription ?? error.localizedDescription
                self.state = .failure(recognitionError)
            }
        }
    }

    func reset() {
        recognitionTask?.cancel()
        recognitionTask = nil
        capturedImage = nil
        state = .idle
    }

    func duplicateIfExists(title: String, artist: String) -> Album? {
        repository.duplicate(forTitle: title, artist: artist)
    }

    func makeDraft(
        title: String,
        artist: String,
        year: Int?,
        genre: String,
        notes: String,
        label: String
    ) -> Album {
        Album(
            title: title,
            artist: artist,
            year: year,
            genre: genre,
            notes: notes,
            label: label,
            imageData: capturedImage?.jpegData(compressionQuality: 0.75)
        )
    }
}
