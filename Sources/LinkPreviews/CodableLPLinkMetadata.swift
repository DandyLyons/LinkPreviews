//
//  File.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import LinkPresentation

public struct CodableLPLinkMetadata: Codable {
    public var value: LPLinkMetadata
    
    public init(_ value: LPLinkMetadata) {
        self.value = value
    }
    
    enum DecodingError: Error {
        case nsKeyedUnarchiverFailedToUnarchiveLPLinkMetadata
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        if let value = try? NSKeyedUnarchiver
            .unarchivedObject(ofClass: LPLinkMetadata.self, from: data) {
            self.value = value
        } else {
            throw DecodingError.nsKeyedUnarchiverFailedToUnarchiveLPLinkMetadata
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: LPLinkMetadata.self,
            requiringSecureCoding: false
        )
        try container.encode(data)
    }
}
