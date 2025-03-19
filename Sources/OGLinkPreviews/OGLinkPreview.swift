//
//  File.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import OpenGraph
import SwiftUI

/// A View that will fetch the Open Graph of a URL and display a preview.
public struct OGLinkPreview<Preview: View, Placeholder: View, Fallback: View>: View {
    @State private var openGraph: OpenGraph?
    public let url: URL
    let transition: AnyTransition
    let onFetchError: @Sendable (any Error) -> Void
    let preview: ((OpenGraph) -> Preview)?
    let placeholder: () -> Placeholder
    let fallback: (URL) -> Fallback
    
    public var body: some View {
        Group {
            if let openGraph {
                if let preview {
                    let _ = print("preview")
                    preview(openGraph).transition(transition)
                } else {
                    let _ = print("openGraphView(og:)")
                    openGraphView(og: openGraph).transition(transition)
                }
            } else {
                let _ = print("placeholderView")
                placeholderView.transition(transition)
            }
        }
        .task { if openGraph == nil { await fetch(url: url) } }
    }
    
    @ViewBuilder func openGraphView(og: OpenGraph) -> some View {
        if let type: String = og[.type] {
            if let typedOGView = TypedOpenGraphView(og: og) {
                let _ = print("typedOGView")
                typedOGView
            } else {
                Text("Could not find a `og:type` property...")
            }
        }
    }
    
    @ViewBuilder var placeholderView: some View {
        EmptyView()
    }
    
    func fetch(url: URL) async {
        let openGraph = OpenGraph.fetch(url: url, completion: handleFetch(result:))
    }
    
    func handleFetch(result: Result<OpenGraph, any Error>) {
        switch result {
            case .success(let openGraph):
                self.openGraph = openGraph
            case .failure(let error):
                switch error {
                    case is OpenGraphParseError:
                        print("OpenGraphParseError: \(error)")
                    case is OpenGraphResponseError:
                        print("OpenGraphResponseError: \(error)")
                    default:
                        print(error)
                }
        }
    }
}

// MARK: Initializers
extension OGLinkPreview {
    public init(
        url: URL,
        transition: AnyTransition = .opacity,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        customPreview: @Sendable @escaping (OpenGraph) -> Preview,
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
        self.openGraph = nil
        self.preview = customPreview
        self.placeholder = placeholder
        self.fallback = fallback
    }
    
    public init?(
        openGraph: OpenGraph,
        transition: AnyTransition = .opacity,
        onFetchError: @escaping @Sendable (Error) -> Void = { _ in },
        customPreview: @Sendable @escaping (OpenGraph) -> Preview,
        @ViewBuilder placeholder: @escaping @Sendable () -> Placeholder = {
            Text("Loading...")
        },
        @ViewBuilder fallback: @escaping @Sendable (URL) -> Fallback = { url in
            Text("\(url.absoluteString)")
        }
    ) {
        guard let urlString = openGraph[.url],
              let url = URL(string: urlString) else {
            return nil
        }
        self.url = url
        self.transition = transition
        self.onFetchError = onFetchError
        self.openGraph = openGraph
        self.preview = customPreview
        self.placeholder = placeholder
        self.fallback = fallback
    }
}

extension OGLinkPreview where Preview == EmptyView {
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
        self.openGraph = nil
        self.preview = nil
        self.placeholder = placeholder
        self.fallback = fallback
    }
}

#Preview {
    let url = URL(string: "https://www.google.com")!
    
    OGLinkPreview(url: url)
}


