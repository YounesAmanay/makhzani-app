/// L10n Extension
///
/// Provides convenient access to localized strings via context.
/// Usage: context.l10n.stringName
library;

import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
