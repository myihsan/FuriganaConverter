// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Clear
  internal static let clear = L10n.tr("Localizable", "Clear")
  /// Convert
  internal static let convert = L10n.tr("Localizable", "Convert")
  /// Converting...
  internal static let converting = L10n.tr("Localizable", "Converting...")
  /// hinagara
  internal static let hinagara = L10n.tr("Localizable", "hinagara")
  /// katakana
  internal static let katakana = L10n.tr("Localizable", "katakana")
  /// Type the text to translate
  internal static let typeTheTextToTranslate = L10n.tr("Localizable", "Type the text to translate")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
