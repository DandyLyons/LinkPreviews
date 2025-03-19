//
//  File.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import OpenGraph
import SwiftUI

/// WIP. A View that will attempt to display the most appropriate preview for the ``OpenGraph``.
public struct TypedOpenGraphView: View {
    let og: OpenGraph
    /// `og:type`
    let type: String
    
    public init?(og: OpenGraph) {
        guard let type = og[.type] else { return nil}
        self.og = og
        self.type = type
    }
    
    public var body: some View {
        switch type {
            case "website":
                if let websiteView = try? WebsitePreview(og: og) {
                    websiteView
                } else {
                    Text("Failed to generate Website Preview")
                }
            case "music":
                EmptyView()
            case "video":
                EmptyView()
            default:
                EmptyView()
        }
    }
}
