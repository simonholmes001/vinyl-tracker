import Foundation
import Vision
import UIKit

struct AlbumRecognitionSuggestion: Equatable {
    let suggestedTitle: String
    let suggestedArtist: String
    let candidateLines: [String]
    let confidence: Float
}

enum AlbumRecognitionError: Error, LocalizedError {
    case invalidImage
    case noTextDetected
    case cancelled
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The captured image could not be processed."
        case .noTextDetected:
            return "No readable text was detected on the album cover."
        case .cancelled:
            return "The recognition request was cancelled."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

final class AlbumRecognitionService {
    private let recognitionQueue = DispatchQueue(label: "app.vinyltracker.recognition", qos: .userInitiated)

    func analyse(image: UIImage) async throws -> AlbumRecognitionSuggestion {
        guard let cgImage = image.cgImage else {
            throw AlbumRecognitionError.invalidImage
        }

        if Task.isCancelled { throw AlbumRecognitionError.cancelled }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: AlbumRecognitionError.underlying(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    continuation.resume(throwing: AlbumRecognitionError.noTextDetected)
                    return
                }

                let ordered = observations.sorted { lhs, rhs in
                    lhs.boundingBox.minY > rhs.boundingBox.minY
                }

                let recognitions: [(String, Float)] = ordered.compactMap { observation in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    let trimmed = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmed.count >= 2 else { return nil }
                    return (trimmed, candidate.confidence)
                }

                guard !recognitions.isEmpty else {
                    continuation.resume(throwing: AlbumRecognitionError.noTextDetected)
                    return
                }

                let candidateLines = recognitions.map { $0.0 }
                let confidence = recognitions.map { $0.1 }.reduce(0, +) / Float(recognitions.count)

                let (title, artist) = AlbumRecognitionService.inferTitleAndArtist(from: candidateLines)

                continuation.resume(returning: AlbumRecognitionSuggestion(
                    suggestedTitle: title,
                    suggestedArtist: artist,
                    candidateLines: candidateLines,
                    confidence: confidence
                ))
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.02

            recognitionQueue.async {
                if Task.isCancelled {
                    continuation.resume(throwing: AlbumRecognitionError.cancelled)
                    return
                }

                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation), options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: AlbumRecognitionError.underlying(error))
                }
            }
        }
    }

    private static func inferTitleAndArtist(from lines: [String]) -> (String, String) {
        guard !lines.isEmpty else { return ("", "") }

        if lines.count == 1 {
            return (lines[0], "")
        }

        // Prefer lines containing typical artist separators as artist candidates.
        let artistKeywords = ["feat", "featuring", "and", "with", "band", "orchestra"]
        let artistCandidate = lines.first { line in
            let lowercased = line.lowercased()
            return artistKeywords.contains { lowercased.contains($0) }
        }

        if let artistCandidate, let artistIndex = lines.firstIndex(of: artistCandidate) {
            var remaining = lines
            remaining.remove(at: artistIndex)
            let titleCandidate = remaining.max(by: { $0.count < $1.count }) ?? remaining.first ?? ""
            return (titleCandidate, artistCandidate)
        }

        // Fall back to longest line as title and the most distinct other line as artist.
        let titleCandidate = lines.max(by: { $0.count < $1.count }) ?? lines[0]
        let artistCandidateFallback = lines.first { $0 != titleCandidate } ?? ""
        return (titleCandidate, artistCandidateFallback)
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
