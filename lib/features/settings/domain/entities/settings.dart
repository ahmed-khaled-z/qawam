/// Domain entity representing user settings
///
/// This is the pure domain representation — no serialization or framework deps.
class Settings {
  final String currency;
  final String language;
  final bool dataSyncEnabled;
  final bool notificationsEnabled;
  final int monthStartDay;

  const Settings({
    this.currency = 'SAR',
    this.language = 'en',
    this.dataSyncEnabled = true,
    this.notificationsEnabled = true,
    this.monthStartDay = 1,
  });
}
