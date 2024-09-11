//
//  UrlsProvider.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 05.09.2024.
//

import Foundation

protocol UrlsProvider {
    func getUrl(originalUrl: URL) -> URL
}
