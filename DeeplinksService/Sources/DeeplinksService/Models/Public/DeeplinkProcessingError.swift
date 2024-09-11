//
//  DeeplinkProcessingError.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 05.09.2024.
//

import Foundation

/// An error that occurs during the processing of a deeplink.
public enum DeeplinkProcessingError: Error {
    /// Indicates that path in the deeplink includes some mistakes
    case pathIsIncorrect(path: DeeplinkPath, error: Error)
    /// Indicates that a parameter in the deeplink path is incorrectly positioned.
    case invalidParameterPosition(parameter: String)
    /// Indicates that parsing the parameters of the deeplink has failed.
    case parsingParametersFailed(Error)
    /// Indicates that handling the deeplink has failed.
    case failedToHandleDeeplink(Error)
}
