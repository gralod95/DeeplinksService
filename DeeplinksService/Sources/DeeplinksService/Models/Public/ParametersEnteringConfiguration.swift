//
//  ParametersEnteringConfiguration.swift
//  DeeplinksService
//
//  Created by Odinokov G. A. on 05.09.2024.
//

import Foundation

/// A configuration structure that defines the rules for parsing parameters in a deeplink.
///
/// The `DeeplinkParametersConfiguration` structure specifies the symbols used to mark the beginning, end,
/// and optionality of parameters in a deeplink. This configuration can be passed to a service factory
/// to control how deeplink parameters are parsed.
public struct DeeplinkParametersConfiguration {
    /// The character that indicates the start of a parameter in the deeplink.
    public let beginningSymbol: Character

    /// The character that indicates the end of a parameter in the deeplink.
    public let endsSymbol: Character

    /// The character that marks a parameter as optional.
    public let optionalSymbol: Character

    /// Initializes a new `DeeplinkParametersConfiguration` with the provided symbols.
    ///
    /// - Parameters:
    ///   - beginningSymbol: The symbol used to denote the beginning of a parameter.
    ///   - endsSymbol: The symbol used to denote the end of a parameter.
    ///   - optionalSymbol: The symbol used to denote an optional parameter.
    public init(beginningSymbol: Character, endsSymbol: Character, optionalSymbol: Character) {
        self.beginningSymbol = beginningSymbol
        self.endsSymbol = endsSymbol
        self.optionalSymbol = optionalSymbol
    }
}
