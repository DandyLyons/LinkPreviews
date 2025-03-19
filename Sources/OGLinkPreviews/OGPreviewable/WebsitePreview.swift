//
//  File.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import OpenGraph
import SwiftUI

struct WebsitePreview: View, OGPreviewable {
    let og_title: String
    /// `og:image`
    let og_image: URL
    /// `og:url`
    let og_url: URL
    /// `og:description`
    let og_description: String?
    /// `og:site_name`
    let og_site_name: String?
    
    static var requiredOGProps: [OpenGraphMetadata] {
        [.title, .image, .url]
    }
    
    static var optionalOGProps: [OpenGraphMetadata] {
        [.description, .siteName]
    }
    
    init(og_title: String, og_image: URL, og_url: URL, og_description: String?, og_site_name: String?) {
        self.og_title = og_title
        self.og_image = og_image
        self.og_url = og_url
        self.og_description = og_description
        self.og_site_name = og_site_name
    }
    
    init(og: OpenGraph) throws(InitError) {
        guard let title = og[.title],
              let og_image = og[.image],
              let image = URL(string: og_image),
              let og_url = og[.url],
              let url = URL(string: og_url) else {
            var missing = [OpenGraphMetadata]()
            for prop in Self.requiredOGProps {
                if og[prop] == nil { missing.append(prop) }
            }
            throw InitError.missing(missing)
        }
        self.og_title = title
        self.og_image = image
        self.og_url = url
        self.og_description = og[.description]
        self.og_site_name = og[.siteName]
    }
    
    enum InitError: Error {
        case missing([OpenGraphMetadata])
    }
    
    var body: some View {
        Text(og_title)
    }
}
