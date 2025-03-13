// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import LinkPresentation
import SwiftUI

// MARK: - UIKit Wrapper (iOS, tvOS)
#if canImport(UIKit)
struct UIKit_LPLinkViewSwiftUI: UIViewRepresentable {
    typealias UIViewType = LPLinkView
    var metadata: LPLinkMetadata?
    
    func makeUIView(context: Context) -> LPLinkView {
        guard let metadata else { return LPLinkView() }
        return LPLinkView(metadata: metadata)
    }
    
    public func updateUIView(_ uiView: LPLinkView, context: Context) {
        
    }
}
#endif

// MARK: - AppKit Wrapper (macOS)
#if canImport(AppKit)
struct AppKit_LPLinkViewSwiftUI: NSViewRepresentable {
    typealias NSViewType = LPLinkView
    var metadata: LPLinkMetadata?
    
    func makeNSView(context: Context) -> LPLinkView {
        guard let metadata else { return LPLinkView() }
        return LPLinkView(metadata: metadata)
    }
    
    public func updateNSView(_ nsView: LPLinkView, context: Context) {
        
    }
}
#endif

public struct LinkPreview<Placeholder: View, Fallback: View>: View {
    @State private var linkMetadata: LPLinkMetadata?
    let url: URL
    let transition: AnyTransition
    let onFetchError: @Sendable (any Error) -> Void
    let placeholder: Placeholder
    let fallback: Fallback
    
    @_disfavoredOverload
    public init(
        _ url: URL,
        anyTransition: AnyTransition = .opacity,
        onFetchError: @escaping @Sendable (any Error) -> Void = { _ in },
        @ViewBuilder placeholder: () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = anyTransition
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.placeholder = placeholder()
        self.fallback = fallback(url)
    }
    
    @available(iOS 17.0, *)
    public init(
        _ url: URL,
        transition: any Transition = .blurReplace,
        onFetchError: @escaping @Sendable (any Error) -> Void = { _ in },
        @ViewBuilder placeholder: () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = AnyTransition(transition)
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.placeholder = placeholder()
        self.fallback = fallback(url)
    }
    
    public var body: some View {
        Group {
            if let linkMetadata {
                if linkMetadata.title != nil {
#if canImport(AppKit)
                    AppKit_LPLinkViewSwiftUI(metadata: linkMetadata)
                        .transition(transition)
#elseif canImport(UIKit)
                    UIKit_LPLinkViewSwiftUI(metadata: linkMetadata)
                        .transition(transition)
                        
#endif
                    
                } else {
                    fallback
                        .transition(transition)
                }
            } else {
                placeholder
                    .transition(transition)
            }
        }
        .task { await fetchMetadata(for: url) }
    }
    
    func fetchMetadata(for url: URL) async {
//        let metadata = await self.performFetchInBackground()
        let metadata = await performFetchInBackground_usingCompletion()
        withAnimation {
            self.linkMetadata = metadata
        }
    }
    
    private func performFetchInBackground_usingCompletion() async -> LPLinkMetadata {
        do {
            let metadata = try await withCheckedThrowingContinuation { @Sendable (continuation: CheckedContinuation<LPLinkMetadata, any Error>) in
                LPMetadataProvider().startFetchingMetadata(for: url) { lpLinkMetadata, error in
                    if let error { continuation.resume(throwing: error) }
                    if let lpLinkMetadata {
                        nonisolated(unsafe) let metadata = lpLinkMetadata
                        continuation.resume(returning: metadata)
                    }
                }
            }
            return metadata
        } catch {
            onFetchError(error)
            // blank metadata to let the view know that the fetch has finished
            // so we shouldn't display the placeholder anymore.
            return LPLinkMetadata()
        }
    }
    
    @available(*, deprecated, renamed: "performFetchInBackground_usingCompletion")
    private nonisolated func performFetchInBackground() async -> LPLinkMetadata {
        let lpLinkMetadata: LPLinkMetadata
        do {
            lpLinkMetadata = try await LPMetadataProvider().startFetchingMetadata(for: url)
        } catch {
            onFetchError(error)
            lpLinkMetadata = LPLinkMetadata()
            // blank metadata to let the view know that the fetch has finished
            // so we shouldn't display the placeholder anymore.
        }
        return lpLinkMetadata
    }
}

#Preview {
    LinkPreview(URL("https://www.google.com")!)
        .frame(width: 400, height: 400)
    
    LinkPreview(
        URL("https://www.google.com")!,
        onFetchError: { error in
            print(error)
        },
        placeholder: {
            Text("Fetching preview...")
        },
        fallback: { url in
            Text("\(url)")
        }
    )
}

