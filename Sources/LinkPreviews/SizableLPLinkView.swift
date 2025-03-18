//
//  File.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import LinkPresentation

/// An LPLinkView whose intrinsic content size matches its frame.
class SizableLPLinkView: LPLinkView {
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(url: URL) {
        super.init(url: url)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }
}
