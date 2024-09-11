//
//  UrlComparator.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 04.09.2024.
//

import Foundation

protocol UrlComparator {
    func urlMatches(url: URL, path: DeeplinkPath) throws -> Bool
}
