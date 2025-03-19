//
//  File.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import OpenGraph

// This should be safe. OpenGraphMetadata is just a simple String enum with no mutation.
extension OpenGraphMetadata: @retroactive @unchecked Sendable {}

// This should be safe. OpenGraph is a struct with only a single immutable property.
extension OpenGraph: @retroactive @unchecked Sendable {}

// This should be safe. OpenGraphParseError is a plain struct
extension OpenGraphParseError: @retroactive @unchecked Sendable {}

