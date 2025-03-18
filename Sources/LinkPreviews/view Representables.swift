//
//  view Representables.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import LinkPresentation
import SwiftUI

// MARK: - UIKit Wrapper (iOS, tvOS)
#if canImport(UIKit)
public struct UIKit_LPLinkViewSwiftUI: UIViewRepresentable {
    public typealias UIViewType = LPLinkView
    var metadata: LPLinkMetadata?
    
    public func makeUIView(context: Context) -> LPLinkView {
        guard let metadata else { return LPLinkView() }
        return LPLinkView(metadata: metadata)
    }
    
    public func updateUIView(_ uiView: LPLinkView, context: Context) {
        
    }
}
#endif

// MARK: - AppKit Wrapper (macOS)
#if canImport(AppKit)
public struct AppKit_LPLinkViewSwiftUI: NSViewRepresentable {
    public typealias NSViewType = LPLinkView
    var metadata: LPLinkMetadata?
    
    public func makeNSView(context: Context) -> LPLinkView {
        guard let metadata else { return LPLinkView() }
        return LPLinkView(metadata: metadata)
    }
    
    public func updateNSView(_ nsView: LPLinkView, context: Context) {
        
    }
}
#endif
