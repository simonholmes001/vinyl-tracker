import SwiftUI

struct CollectionEditorView: View {
    @State private var name: String
    @State private var detail: String

    let onSave: (String, String) -> Void
    let onCancel: () -> Void

    init(initialName: String, initialDetail: String, onSave: @escaping (String, String) -> Void, onCancel: @escaping () -> Void) {
        _name = State(initialValue: initialName)
        _detail = State(initialValue: initialDetail)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        Form {
            Section("Collection") {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)

                TextField("Description", text: $detail, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
        .navigationTitle(name.isEmpty ? "New Collection" : "Edit Collection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    onCancel()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    onSave(name, detail)
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
