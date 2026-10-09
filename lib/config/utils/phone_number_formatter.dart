abstract final class PhoneNumberFormatter {
  PhoneNumberFormatter._();

  static String stripLeadingTrunkZero(String phoneNumber) {
    return phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber;
  }
}
