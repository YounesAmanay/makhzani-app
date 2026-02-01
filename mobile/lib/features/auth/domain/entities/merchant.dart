/// Merchant Entity
///
/// This is a DOMAIN entity - it represents the core business concept
/// of a merchant in our application. It has NO dependencies on:
/// - Flutter
/// - External packages
/// - Data layer (API, database)
///
/// Why? Because domain entities are the HEART of your app.
/// They should be pure Dart and never change due to API changes.
library;

class Merchant {
  /// Unique identifier from the backend
  final String id;

  /// Phone number used for authentication (format: +212XXXXXXXXX)
  final String phoneNumber;

  /// Business name (nullable - merchant might not have set it yet)
  final String? businessName;

  /// Subscription status: 'trial', 'paid', or 'suspended'
  final String subscriptionStatus;

  /// When the trial period ends (null if not on trial or already paid)
  final DateTime? trialEndsAt;

  /// Const constructor - allows compile-time constant creation
  /// All fields are final = immutable (cannot be changed after creation)
  const Merchant({
    required this.id,
    required this.phoneNumber,
    this.businessName,
    required this.subscriptionStatus,
    this.trialEndsAt,
  });

  /// Helper to check if merchant is on active trial
  bool get isOnTrial =>
      subscriptionStatus == 'trial' &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());

  /// Helper to check if subscription is active (trial or paid)
  bool get hasActiveSubscription => subscriptionStatus == 'paid' || isOnTrial;

  /// Helper to get days remaining in trial
  int? get trialDaysRemaining {
    if (trialEndsAt == null) return null;
    final difference = trialEndsAt!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }
}
