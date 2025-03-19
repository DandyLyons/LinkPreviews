//
//  OGPreviewable.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import OpenGraph
import SwiftUI

protocol OGPreviewable: View {
    nonisolated static var requiredOGProps: [OpenGraphMetadata] { get }
    nonisolated static var optionalOGProps: [OpenGraphMetadata] { get }
}

extension OGPreviewable {
    nonisolated static var optionalOGProps: [OpenGraphMetadata] { [] }
}

