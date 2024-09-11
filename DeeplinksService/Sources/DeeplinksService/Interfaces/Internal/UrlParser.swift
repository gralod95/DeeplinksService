//
//  UrlParser.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 04.09.2024.
//

import Foundation

protocol UrlParser {
    func getPathInfo(from url: URL) -> UrlInfo
    func makeParameters<Parameters: Decodable>(from parametersDictionary: [String: String]) -> Result<Parameters, Error>
}
