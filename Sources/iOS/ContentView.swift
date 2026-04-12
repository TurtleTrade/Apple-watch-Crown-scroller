import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var connectivity = PhoneConnectivity.shared
    @State private var bookText: String = ReaderView.sampleText
    @State private var showImporter = false
    @State private var importError: String?

    var body: some View {
        NavigationStack {
            ReaderView(connectivity: connectivity, bookText: $bookText)
                .navigationTitle("Reading")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Import .txt") { showImporter = true }
                    }
                }
                .fileImporter(
                    isPresented: $showImporter,
                    allowedContentTypes: [.plainText],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case let .success(urls):
                        guard let url = urls.first else { return }
                        let accessing = url.startAccessingSecurityScopedResource()
                        defer {
                            if accessing { url.stopAccessingSecurityScopedResource() }
                        }
                        do {
                            let data = try Data(contentsOf: url)
                            if let s = String(data: data, encoding: .utf8) {
                                bookText = s
                            } else if let s = String(data: data, encoding: .utf16) {
                                bookText = s
                            } else {
                                importError = "Could not decode this file as UTF-8 or UTF-16 text."
                            }
                        } catch {
                            importError = error.localizedDescription
                        }
                    case .failure:
                        break
                    }
                }
                .alert("Import failed", isPresented: Binding(
                    get: { importError != nil },
                    set: { if !$0 { importError = nil } }
                )) {
                    Button("OK", role: .cancel) { importError = nil }
                } message: {
                    Text(importError ?? "")
                }
        }
    }
}

private extension ReaderView {
    static var sampleText: String {
        """
        Crown Reader

        Put your book text here, or tap Import .txt to load a plain text file.

        On your Apple Watch, open the Crown app and turn the Digital Crown to scroll this page on your iPhone. Both devices should be unlocked; the Watch app works best when the phone app is in the foreground.

        This sample paragraph repeats so you can try scrolling.

        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

        Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

        """
    }
}
