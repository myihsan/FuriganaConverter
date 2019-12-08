// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Acknowledgements
  internal static let acknowledgements = L10n.tr("Localizable", "Acknowledgements")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "Cancel")
  /// Clear
  internal static let clear = L10n.tr("Localizable", "Clear")
  /// Clear History
  internal static let clearHistory = L10n.tr("Localizable", "Clear History")
  /// Convert
  internal static let convert = L10n.tr("Localizable", "Convert")
  /// Converting Failed
  internal static let convertingFailed = L10n.tr("Localizable", "Converting Failed")
  /// Converting...
  internal static let converting = L10n.tr("Localizable", "Converting...")
  /// hinagara
  internal static let hinagara = L10n.tr("Localizable", "hinagara")
  /// katakana
  internal static let katakana = L10n.tr("Localizable", "katakana")
  /// Later
  internal static let later = L10n.tr("Localizable", "Later")
  /// OK
  internal static let ok = L10n.tr("Localizable", "OK")
  /// Paste
  internal static let paste = L10n.tr("Localizable", "Paste")
  /// Please try again with a shorter text.
  internal static let pleaseTryAgainWithAShorterText = L10n.tr("Localizable", "Please try again with a shorter text.")
  /// Please wait until tomorrow.
  internal static let pleaseWaitUntilTomorrow = L10n.tr("Localizable", "Please wait until tomorrow.")
  /// Rate Limit Exceeded
  internal static let rateLimitExceeded = L10n.tr("Localizable", "Rate Limit Exceeded")
  /// Retry
  internal static let retry = L10n.tr("Localizable", "Retry")
  /// Settings
  internal static let settings = L10n.tr("Localizable", "Settings")
  /// Show Keyboard Automatically
  internal static let showKeyboardAutomatically = L10n.tr("Localizable", "Show Keyboard Automatically")
  /// Text Too Long
  internal static let textTooLong = L10n.tr("Localizable", "Text Too Long")
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
