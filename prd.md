# Product Requirements Document (PRD)  
**Vinyl Collection Tracker (iOS)**  
**Version:** 1.3  
**Date:** August 27, 2025  
**Status:** Draft – Revised  

---

## 1. Introduction & Vision

The Vinyl Collection Tracker is an iOS app designed to help vinyl enthusiasts **avoid duplicate purchases**, **catalog collections effortlessly**, and **bridge physical records with digital Apple Music libraries**.  

The app leverages the iPhone’s **camera**, **Core ML**, and **Discogs/Apple Music APIs** to identify records, check for duplicates, and enrich metadata.  

**Vision:** Become the *must-have mobile companion* for every record store visit by making collection tracking instantaneous, reliable, and beautifully designed.  

---

## 2. User Personas

- **The Collector (Primary):** Regularly buys vinyl, struggles to remember every LP owned, values speed + convenience in-store.  
- **The Curator:** Wants deep metadata (tracklists, liner notes, labels, genres) and collection insights.  
- **The Hybrid Listener:** Collects vinyl but also listens digitally; values Apple Music sync.  

---

## 3. Functional Requirements

### Epic: Instant Album Recognition & Duplicate Check
- **US 1.1:** As a user, I can scan an album cover with my iPhone camera to instantly identify it.  
- **US 1.2:** The app confirms clearly: *“Owned”* or *“Not in Collection.”*  
- **US 1.3:** If new, I can tap **Add to Collection** to store it immediately.  

### Epic: Collection Management & Cataloging
- **US 2.1:** As a new user, I can batch-add my current collection by scanning covers.  
- **US 2.2:** I can browse my collection in a **visual grid of album covers**.  
- **US 2.3:** I can tap any album to view: artwork, tracklist, artist info, label, genre, release year, and liner notes.  
- **US 2.4:** I can manually add or search albums if image recognition fails.  

### Epic: Apple Music Integration
- **US 3.1:** When adding an album, I’m prompted to add its **digital version** to a “Vinyl Collection” playlist in Apple Music.  
- **US 3.2:** I can retroactively link existing cataloged albums to Apple Music entries.  

### Epic: Extended Metadata
- Album artwork (front + back cover scans).  
- Recording date, label, genre, pressing info.  
- Notes field for collector annotations (e.g., “signed copy,” “first press”).  

---

## 4. Non-Functional Requirements

### 4.1 Platform & Development
- **OS:** iOS (latest + one prior).  
- **Devices:** iPhone only (iPad later).  
- **Language:** Swift + SwiftUI.  
- **Architecture:** MVVM or VIPER for modularity.  
- **TDD Requirement:**  
  - Unit tests with XCTest.  
  - UI tests with XCUITest.  
  - >85% coverage mandatory.  

### 4.2 Core Technology
- **Image Recognition:** Core ML + Vision (offline-first).  
- **Music Metadata:** Discogs or MusicBrainz API.  
- **Apple Music:** MusicKit for playlist integration.  
- **Data Storage:**  
  - Local: Core Data / SwiftData.  
  - Sync: iCloud for backup + multi-device access.  

### 4.3 Security & Privacy
- **No album data leaves the device** unless syncing with iCloud.  
- Apple Sign-In as optional login (avoid email/password overhead).  
- Full GDPR + CCPA compliance for data portability/deletion.  

### 4.4 UX & Performance
- **Scan to Result:** <2 seconds.  
- **Offline Capability:** Duplicate-check works fully offline; metadata fetch requires connection.  
- **Design:** Minimalist, album-art first. Primary scan button is immediate on launch.  

---

## 5. Core ML Training Pipeline

The album recognition system will be powered by a **custom Core ML model** trained on album cover datasets.  

### 5.1 Dataset Preparation
- **Sources:** Discogs image dumps, MusicBrainz cover art archive, and user-provided training samples.  
- **Labels:** Each album cover must be tagged with unique identifiers (artist + album title + year).  
- **Augmentation:** Apply rotation, cropping, glare simulation, and color shifts to simulate record store lighting and wear conditions.  
- **Split:** 70% training, 15% validation, 15% test.  

### 5.2 Model Training
- **Framework:** PyTorch or TensorFlow → converted to Core ML via `coremltools`.  
- **Architecture:**  
  - Base: MobileNetV3 or EfficientNet (optimized for mobile inference).  
  - Output: Album ID classification + embedding vector for similarity search.  
- **Training Hardware:** Cloud GPU (e.g., AWS Sagemaker, Azure ML, or local M-series Mac).  
- **Evaluation:** Accuracy, precision/recall, F1 score. Target: >95% recognition accuracy.  

### 5.3 Model Deployment
- **Conversion:** Use `coremltools` to convert trained model into `.mlmodel`.  
- **Integration:** App bundles the Core ML model locally.  
- **Inference:**  
  - Vision framework captures image frames.  
  - Core ML model classifies and returns album ID.  
  - Local DB lookup confirms duplicate status.  

### 5.4 Continuous Improvement
- **User Feedback Loop:** If a recognition fails, user can manually correct album → correction stored for retraining.  
- **Model Update Pipeline:**  
  - Aggregate new labeled data (user corrections + new releases).  
  - Retrain quarterly.  
  - Push updated `.mlmodel` via app updates or on-device Core ML model updates.  

---

## 6. Future Scope

- **Wishlist:** Scan an album → add to Wishlist instead of Collection.  
- **Statistics & Insights:** Breakdown by genre, artist, year, estimated value (via Discogs marketplace).  
- **iPadOS:** Optimized for larger display browsing.  
- **Social Sharing:** Share new additions with friends.  
- **AR Mode:** Place album covers in a virtual shelf for immersive browsing.  

---

## 7. Risks & Constraints

- API dependency: Discogs/MusicBrainz uptime & rate limits.  
- Apple Music integration limited by user region/subscription.  
- Album artwork recognition accuracy varies with lighting/cover wear.  

---

## 8. Success Metrics

- **Recognition Accuracy:** >95% correct on first scan.  
- **Speed:** Average recognition <2 seconds.  
- **Engagement:** Avg. albums cataloged per user ≥ 50.  
- **Retention:** >40% users active at Day 30.  
- **Coverage:** ≥85% test coverage across all modules.  

---

## 9. Deliverables

1. SwiftUI app with modular architecture (MVVM/VIPER).  
2. Core ML model trained/tuned for album recognition.  
3. Discogs/MusicBrainz + MusicKit integration.  
4. iCloud sync for persistence.  
5. TDD test suite (unit + UI).  
6. High-fidelity UI mockups (Figma/Sketch).  
7. App Store deploy-ready build.  
8. Core ML training pipeline (dataset → training → `.mlmodel` → app integration).  

---

## 10. Phased Roadmap

**MVP (Phase 1):**  
- Album recognition + duplicate check.  
- Collection storage (Core Data + iCloud sync).  
- Manual add/search.  
- Apple Music integration (basic add-to-playlist).  
- First Core ML model shipped with app.  

**Phase 2 Enhancements:**  
- Metadata enrichment (liner notes, label info).  
- Wishlist + stats.  
- Social sharing.  
- iPadOS version.  
- AR browsing.  
- Continuous Core ML model updates.  

---

## 11. Technical Architecture & Data Flow (Draft)

### 11.1 Component Overview (Mermaid)

```mermaid
flowchart LR
  U[User] -->|Scan| App[iOS App (SwiftUI)]
  App --> Cam[Camera]
  Cam --> Vis[Vision Framework]
  Vis --> ML[Core ML Model (.mlmodel)]
  ML -->|Album ID / Embedding| DB[(Local DB<br/>Core Data / SwiftData)]
  DB -->|Duplicate? Owned/Not| App

  App -->|If needed: fetch metadata| Meta[Discogs / MusicBrainz API]
  App -->|Add to playlist / Link| AM[Apple Music via MusicKit]

  DB <-->|Sync| iCloud[iCloud Sync]

  subgraph Device
    App
    Cam
    Vis
    ML
    DB
  end

  subgraph Cloud
    iCloud
    Meta
    AM
  end

Notes
Offline-first path: Camera → Vision → Core ML → Local DB yields Owned/Not without network.
Online enrichments: Metadata fetch (Discogs/MusicBrainz) and Apple Music linking are optional and network-dependent.
Privacy: Images are processed on-device; only user-approved sync goes to iCloud.

11.2 Scan-to-Decision Sequence

sequenceDiagram
  participant U as User
  participant UI as iOS App (SwiftUI)
  participant Cam as Camera
  participant Vis as Vision
  participant ML as Core ML
  participant DB as Local DB (Core Data)
  participant Meta as Discogs/MusicBrainz
  participant AM as Apple Music (MusicKit)

  U->>UI: Launch app (Scan view default)
  U->>UI: Tap Scan
  UI->>Cam: Start camera capture
  Cam-->>Vis: Frame buffer (album cover)
  Vis->>ML: Preprocessed image
  ML-->>UI: Predicted AlbumID + confidence (and/or embedding)
  UI->>DB: Lookup AlbumID (or nearest embedding)
  DB-->>UI: Hit? (Owned / Not in Collection)

  alt Not in Collection
    UI->>U: Show "Not in Collection" + Add to Collection
    U->>UI: Confirm Add
    UI->>DB: Insert album record
    par Optional enrich
      UI->>Meta: Fetch metadata/artwork
      Meta-->>UI: Album details
      UI->>DB: Update record with metadata
    and Optional Apple Music
      UI->>AM: Add to "Vinyl Collection" playlist
      AM-->>UI: Success/Failure
    end
  else Owned
    UI->>U: Show "Owned" + details
  end

Key Decisions
Keep the inference path fully on-device.
Batch and ship model updates via app releases (or signed model packages) to retain control and QA.
Use embeddings for nearest-neighbor fallback when classification confidence is low.