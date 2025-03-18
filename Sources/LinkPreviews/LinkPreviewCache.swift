//
//  LinkPreviewCache.swift
//  LinkPreviews
//
//  Created by Daniel Lyons on 2025-03-18.
//

import Foundation
import LinkPresentation

public struct LinkPreviewCache: Codable {
    public var cache: [URL: LinkPreviewCacheItem]
    
    public mutating func refresh() async {
        for (url, metadata) in cache {
            if metadata.expirationDate < Date.now {
                do {
                    let refreshed = try await metadata.refreshed(experationDate: .in24Hours)
                    cache[url] = refreshed
                } catch {
                    continue
                }
            }
        }
    }

    /// EXPERIMENTAL: Attempts to refresh metadata for every item in the cache.
    ///
    /// On each refresh error, this function leaves the cache item in place and moves to the next.
    mutating func _refreshAll(expirationDate: Date = .in24Hours) async {
        for (url, metadata) in cache {
            do {
                let refreshed = try await metadata.refreshed(experationDate: expirationDate)
                cache[url] = refreshed
            } catch {
                continue
            }
        }
    }
}

public struct LinkPreviewCacheItem: Codable {
    public var linkMetadata: CodableLPLinkMetadata
    public var expirationDate: Date
    
    public init(linkMetadata: CodableLPLinkMetadata, expirationDate: Date = .in24Hours) {
        self.linkMetadata = linkMetadata
        self.expirationDate = expirationDate
    }
    
    /// returns a new ``LinkPreviewCacheItem`` with refreshed metadata
    func refreshed(experationDate: Date = .in24Hours) async throws -> Self? {
        guard let url = self.linkMetadata.value.originalURL else {
            return nil
        }
        
        let metadata = try await withCheckedThrowingContinuation { @Sendable (continuation: CheckedContinuation<LPLinkMetadata, any Error>) in
            LPMetadataProvider().startFetchingMetadata(for: url) { lpLinkMetadata, error in
                if let error { continuation.resume(throwing: error) }
                if let lpLinkMetadata {
                    nonisolated(unsafe) let metadata = lpLinkMetadata
                    continuation.resume(returning: metadata)
                }
            }
        }
        
        return Self(
            linkMetadata: CodableLPLinkMetadata(metadata),
            expirationDate: experationDate
        )
    }
}

extension Date {
    /// Naive 24 hours from now, ignoring locale, and time zone.
    ///
    /// 60 * 60 * 24 seconds from now.
    public static var in24Hours: Date {
        .now.addingTimeInterval(60 * 60 * 24)
    }
}

