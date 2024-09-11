//
//  DeeplinkPath.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 03.09.2024.
//

import Foundation

/// Path used to identify a specific deeplink.
public enum DeeplinkPath: Equatable {
    /// List of exact paths that identify the deeplink.
    case paths([String])
    /// Regular expression pattern to identify the deeplink.
    case regularExpression(String)
}
