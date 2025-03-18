// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import LinkPresentation
import SwiftUI

public struct LinkPreview<Preview: View, Placeholder: View, Fallback: View>: View {
    @State private var linkMetadata: LPLinkMetadata?
    let url: URL
    let transition: AnyTransition
    let onFetchError: @Sendable (any Error) -> Void
    let preview: ((LPLinkMetadata) -> Preview)?
    let placeholder: () -> Placeholder
    let fallback: (URL) -> Fallback
    
    public var body: some View {
        Group {
            if let linkMetadata {
                // fetchMetadata(for: URL) did finish
                if linkMetadata.title == nil {
                    // the linkMetadata is missing data
                    fallback(url).transition(transition)
                } else {
                    // the linkMetadata has enough info to generate a preview
                    if let preview {
                        // the caller provided a custom preview
                        preview(linkMetadata).transition(transition)
                    } else {
                        // the caller did not provide a custom preview
                        defaultPreview(for: linkMetadata).transition(transition)
                    }
                }
            } else {
                placeholder().transition(transition)
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
            // return blank metadata to let the view know that the fetch has finished
            // so we shouldn't display the placeholder anymore.
            return LPLinkMetadata()
        }
    }
    
#if canImport(AppKit)
    func defaultPreview(for linkMetadata: LPLinkMetadata) -> AppKit_LPLinkViewSwiftUI {
        AppKit_LPLinkViewSwiftUI(metadata: linkMetadata)
    }
#elseif canImport(UIKit)
    func defaultPreview(for linkMetadata: LPLinkMetadata) -> UIKit_LPLinkViewSwiftUI {
        UIKit_LPLinkViewSwiftUI(metadata: linkMetadata)
    }
#endif
}

// MARK: Initializers
extension LinkPreview {
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
    public init(
        url: URL,
        transition: some Transition = .blurReplace,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        customPreview: @escaping @Sendable ((LPLinkMetadata) -> Preview),
        @ViewBuilder placeholder: @escaping @Sendable () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping @Sendable (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = AnyTransition(transition)
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.preview = customPreview
        self.placeholder = placeholder
        self.fallback = fallback
    }
    
    @_disfavoredOverload
    public init(
        url: URL,
        transition: AnyTransition = .opacity,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        customPreview: @escaping @Sendable ((LPLinkMetadata) -> Preview),
        @ViewBuilder placeholder: @escaping @Sendable () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping @Sendable (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = transition
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.preview = customPreview
        self.placeholder = placeholder
        self.fallback = fallback
    }
}

#if canImport(AppKit)
extension LinkPreview where Preview == AppKit_LPLinkViewSwiftUI {
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, *)
    public init(
        url: URL,
        transition: some Transition = .blurReplace,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        @ViewBuilder placeholder: @escaping @Sendable () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping @Sendable (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = AnyTransition(transition)
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.preview = nil
        self.placeholder = placeholder
        self.fallback = fallback
    }
    
    @_disfavoredOverload
    public init(
        url: URL,
        transition: AnyTransition = .opacity,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        @ViewBuilder placeholder: @escaping @Sendable () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping @Sendable (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = transition
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.preview = nil
        self.placeholder = placeholder
        self.fallback = fallback
    }
}
#elseif canImport(UIKit)
extension LinkPreview where Preview == UIKit_LPLinkViewSwiftUI {
    @available(iOS 17.0, *)
    public init(
        url: URL,
        transition: some Transition = .blurReplace,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        @ViewBuilder placeholder: @escaping @Sendable () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping @Sendable (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = AnyTransition(transition)
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.preview = nil
        self.placeholder = placeholder
        self.fallback = fallback
    }
    
    @_disfavoredOverload
    public init(
        url: URL,
        transition: AnyTransition = .opacity,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        @ViewBuilder placeholder: @escaping @Sendable () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping @Sendable (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        self.url = url
        self.transition = transition
        self.onFetchError = onFetchError
        self.linkMetadata = nil
        self.preview = nil
        self.placeholder = placeholder
        self.fallback = fallback
    }
}
#endif

// MARK: Previews
#Preview {
    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
        LinkPreview(url: URL("https://www.google.com")!)
            .frame(width: 400, height: 400)
        
        LinkPreview(url: URL("this is not a valid url")!,
                    onFetchError: { error in print(error)},
                    placeholder: { Text("Fetching preview...") },
                    fallback: { url in Text("\(url)")}
        )
        
    } else {
        // Fallback on earlier versions
        LinkPreview(url: URL("https://www.google.com")!)
            .frame(width: 400, height: 400)
        
        LinkPreview(url: URL("this is not a valid url")!,
                    onFetchError: { error in print(error)},
                    placeholder: { Text("Fetching preview...") },
                    fallback: { url in Text("\(url)")}
        )
    }
    
}

