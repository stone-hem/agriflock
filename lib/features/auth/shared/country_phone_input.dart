import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Country {
  final String name;
  final String code;
  final String emoji;
  final String unicode;
  final String image;
  final String dialCode;

  Country({
    required this.name,
    required this.code,
    required this.emoji,
    required this.unicode,
    required this.image,
    required this.dialCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      code: json['code'],
      emoji: json['emoji'],
      unicode: json['unicode'],
      image: json['image'],
      dialCode: json['dial_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'emoji': emoji,
      'unicode': unicode,
      'image': image,
      'dial_code': dialCode,
    };
  }
}

class PhoneValidationRules {
  static final Map<String, PhoneRule> rules = {
    'US': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'KE': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'GB': PhoneRule(length: 10, format: 'XXXX XXX XXX'),
    'IN': PhoneRule(length: 10, format: 'XXXXX XXXXX'),
    'NG': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'ZA': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'AU': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'CA': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'DE': PhoneRule(length: 10, format: 'XXX XXXXXXX'),
    'FR': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'BR': PhoneRule(length: 11, format: '(XX) XXXXX-XXXX'),
    'JP': PhoneRule(length: 10, format: 'XX-XXXX-XXXX'),
    'AD': PhoneRule(length: 6, format: 'XXX XXX'),
    'AE': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'AF': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'AG': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'AI': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'AL': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'AM': PhoneRule(length: 8, format: 'XX XXXXXX'),
    'AO': PhoneRule(length: 9, format: 'XXX XXX XXX XXX'),
    'AQ': PhoneRule(length: 6, format: 'XXX XXX'),
    'AR': PhoneRule(length: 10, format: 'XX XXXX-XXXX'),
    'AS': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'AT': PhoneRule(length: 10, format: 'XXX XXXXXXXX'),
    'AW': PhoneRule(length: 7, format: 'XXX XXXX'),
    'AX': PhoneRule(length: 7, format: 'XX XXXXX'),
    'AZ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'BA': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'BB': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'BD': PhoneRule(length: 10, format: 'XX-XXXX-XXXX'),
    'BE': PhoneRule(length: 9, format: 'XXX XX XX XX'),
    'BF': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'BG': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'BH': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'BI': PhoneRule(length: 8, format: 'XX XX XXXX'),
    'BJ': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'BL': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'BM': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'BN': PhoneRule(length: 7, format: 'XXX XXXX'),
    'BO': PhoneRule(length: 8, format: 'X XXX XXXX'),
    'BS': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'BT': PhoneRule(length: 7, format: 'XX XXX XXX'),
    'BW': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'BY': PhoneRule(length: 9, format: 'XX XXX-XX-XX'),
    'BZ': PhoneRule(length: 7, format: 'XXX-XXXX'),
    'CC': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'CD': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'CF': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'CG': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'CH': PhoneRule(length: 9, format: 'XX XXX XX XX'),
    'CI': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'CK': PhoneRule(length: 5, format: 'XX XXX'),
    'CL': PhoneRule(length: 9, format: 'X XXXX XXXX'),
    'CM': PhoneRule(length: 9, format: 'XXXX XXXX'),
    'CN': PhoneRule(length: 11, format: 'XXX XXXX XXXX'),
    'CO': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'CR': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'CU': PhoneRule(length: 8, format: 'X XXX XXXX'),
    'CV': PhoneRule(length: 7, format: 'XXX XXXX'),
    'CX': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'CY': PhoneRule(length: 8, format: 'XX XXXXXX'),
    'CZ': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'DJ': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'DK': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'DM': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'DO': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'DZ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'EC': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'EE': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'EG': PhoneRule(length: 10, format: 'XX XXXX XXXX'),
    'ER': PhoneRule(length: 7, format: 'X XXX XXX'),
    'ES': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'ET': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'FI': PhoneRule(length: 9, format: 'XX XXX XX XX'),
    'FJ': PhoneRule(length: 7, format: 'XXX XXXX'),
    'FK': PhoneRule(length: 5, format: 'XXXXX'),
    'FM': PhoneRule(length: 7, format: 'XXX XXXX'),
    'FO': PhoneRule(length: 6, format: 'XXX XXX'),
    'GA': PhoneRule(length: 8, format: 'X XX XX XX'),
    'GD': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'GE': PhoneRule(length: 9, format: 'XXX XX XX XX'),
    'GF': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'GG': PhoneRule(length: 10, format: 'XXXXX XXXXX'),
    'GH': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'GI': PhoneRule(length: 8, format: 'XXX XXXX'),
    'GL': PhoneRule(length: 6, format: 'XX XX XX'),
    'GM': PhoneRule(length: 7, format: 'XXX XXXX'),
    'GN': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'GP': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'GQ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'GR': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'GT': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'GU': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'GW': PhoneRule(length: 7, format: 'XXX XXXX'),
    'GY': PhoneRule(length: 7, format: 'XXX XXXX'),
    'HK': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'HN': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'HR': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'HT': PhoneRule(length: 8, format: 'XX XX XXXX'),
    'HU': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'ID': PhoneRule(length: 10, format: 'XX XXXX XXXX'),
    'IE': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'IL': PhoneRule(length: 9, format: 'XX-XXX-XXXX'),
    'IM': PhoneRule(length: 10, format: 'XXXXX XXXXX'),
    'IO': PhoneRule(length: 7, format: 'XXX XXXX'),
    'IQ': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'IR': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'IS': PhoneRule(length: 7, format: 'XXX XXXX'),
    'IT': PhoneRule(length: 10, format: 'XXX XXXX XXX'),
    'JE': PhoneRule(length: 10, format: 'XXXXX XXXXX'),
    'JM': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'JO': PhoneRule(length: 9, format: 'X XXXX XXXX'),
    'KG': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'KH': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'KI': PhoneRule(length: 5, format: 'XX XXX'),
    'KM': PhoneRule(length: 7, format: 'XXX XXXX'),
    'KN': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'KP': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'KR': PhoneRule(length: 10, format: 'XX-XXX-XXXX'),
    'KW': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'KY': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'KZ': PhoneRule(length: 10, format: 'XXX XXX-XX-XX'),
    'LA': PhoneRule(length: 9, format: 'XX XX XXX XXX'),
    'LB': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'LC': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'LI': PhoneRule(length: 7, format: 'XXX XXXX'),
    'LK': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'LR': PhoneRule(length: 8, format: 'XX XXX XXXX'),
    'LS': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'LT': PhoneRule(length: 8, format: 'XXX XXXXX'),
    'LU': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'LV': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'LY': PhoneRule(length: 9, format: 'XX-XXX-XXXX'),
    'MA': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'MC': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'MD': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'ME': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'MF': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'MG': PhoneRule(length: 9, format: 'XX XX XX XXX'),
    'MH': PhoneRule(length: 7, format: 'XXX-XXXX'),
    'MK': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'ML': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'MM': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'MN': PhoneRule(length: 8, format: 'XX XX XXXX'),
    'MO': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'MP': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'MQ': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'MR': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'MS': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'MT': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'MU': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'MV': PhoneRule(length: 7, format: 'XXX-XXXX'),
    'MW': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'MX': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'MY': PhoneRule(length: 9, format: 'XX-XXX XXXX'),
    'MZ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'NA': PhoneRule(length: 8, format: 'XX XXX XXXX'),
    'NC': PhoneRule(length: 6, format: 'XX.XX.XX'),
    'NE': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'NF': PhoneRule(length: 5, format: 'XXXXX'),
    'NI': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'NL': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'NO': PhoneRule(length: 8, format: 'XXX XX XXX'),
    'NP': PhoneRule(length: 10, format: 'XX-XXXX-XXXX'),
    'NR': PhoneRule(length: 7, format: 'XXX XXXX'),
    'NU': PhoneRule(length: 4, format: 'XXXX'),
    'NZ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'OM': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'PA': PhoneRule(length: 8, format: 'XXXX-XXXX'),
    'PE': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'PF': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'PG': PhoneRule(length: 8, format: 'XXX XXXX'),
    'PH': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'PK': PhoneRule(length: 10, format: 'XXX XXXXXXX'),
    'PL': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'PM': PhoneRule(length: 6, format: 'XX XX XX'),
    'PN': PhoneRule(length: 5, format: 'XXXXX'),
    'PR': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'PS': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'PT': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'PW': PhoneRule(length: 7, format: 'XXX XXXX'),
    'PY': PhoneRule(length: 9, format: 'XXX XXXXXXX'),
    'QA': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'RE': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'RO': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'RS': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'RU': PhoneRule(length: 10, format: 'XXX XXX-XX-XX'),
    'RW': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'SA': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'SB': PhoneRule(length: 7, format: 'XXX XXXX'),
    'SC': PhoneRule(length: 7, format: 'X XXX XXX'),
    'SD': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'SE': PhoneRule(length: 9, format: 'XX XXX XX XX'),
    'SG': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'SH': PhoneRule(length: 4, format: 'XXXX'),
    'SI': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'SJ': PhoneRule(length: 8, format: 'XXX XX XXX'),
    'SK': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'SL': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'SM': PhoneRule(length: 10, format: 'XXXXX XXXXX'),
    'SN': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'SO': PhoneRule(length: 8, format: 'X XXXXXXX'),
    'SR': PhoneRule(length: 7, format: 'XXX-XXXX'),
    'SS': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'ST': PhoneRule(length: 7, format: 'XX XXXXX'),
    'SV': PhoneRule(length: 8, format: 'XXXX XXXX'),
    'SY': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'SZ': PhoneRule(length: 8, format: 'XX XX XXXX'),
    'TC': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'TD': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'TG': PhoneRule(length: 8, format: 'XX XX XX XX'),
    'TH': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'TJ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'TK': PhoneRule(length: 4, format: 'XXXX'),
    'TL': PhoneRule(length: 7, format: 'XXX XXXX'),
    'TM': PhoneRule(length: 8, format: 'XX XXXXXX'),
    'TN': PhoneRule(length: 8, format: 'XX XXX XXX'),
    'TO': PhoneRule(length: 5, format: 'XX XXX'),
    'TR': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'TT': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'TV': PhoneRule(length: 5, format: 'XX XXX'),
    'TW': PhoneRule(length: 9, format: 'X XXXX XXXX'),
    'TZ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'UA': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'UG': PhoneRule(length: 9, format: 'XXX XXX XXX'),
    'UY': PhoneRule(length: 8, format: 'X XXX XXXX'),
    'UZ': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'VA': PhoneRule(length: 10, format: 'XX XXXX XXXX'),
    'VC': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'VE': PhoneRule(length: 10, format: 'XXX XXX XXXX'),
    'VG': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'VI': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'VN': PhoneRule(length: 9, format: 'XXX XXX XXXX'),
    'VU': PhoneRule(length: 7, format: 'XXX XXXX'),
    'WF': PhoneRule(length: 6, format: 'XX XX XX'),
    'WS': PhoneRule(length: 7, format: 'XX XXXX'),
    'YE': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'YT': PhoneRule(length: 9, format: 'X XX XX XX XX'),
    'ZM': PhoneRule(length: 9, format: 'XX XXX XXXX'),
    'ZW': PhoneRule(length: 9, format: 'XX XXX XXXX'),
  };

  static PhoneRule? getRule(String countryCode) {
    return rules[countryCode.toUpperCase()];
  }
}

class PhoneRule {
  final int length;
  final String format;

  PhoneRule({required this.length, required this.format});
}

// Custom TextInputFormatter that formats phone numbers as user types
class PhoneNumberFormatter extends TextInputFormatter {
  final String countryCode;

  PhoneNumberFormatter(this.countryCode);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final rule = PhoneValidationRules.getRule(countryCode);
    if (rule == null) return newValue;

    // Get only digits from the new value
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Don't allow more digits than the format requires
    final maxLength = rule.length;
    final limitedDigits = digitsOnly.length > maxLength
        ? digitsOnly.substring(0, maxLength)
        : digitsOnly;

    // Apply the format
    final formatted = _applyFormat(limitedDigits, rule.format);

    // Calculate cursor position
    int selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  String _applyFormat(String digits, String format) {
    String result = '';
    int digitIndex = 0;

    for (int i = 0; i < format.length && digitIndex < digits.length; i++) {
      if (format[i] == 'X') {
        result += digits[digitIndex];
        digitIndex++;
      } else {
        result += format[i];
      }
    }

    return result;
  }
}

class CountryPhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String>? customValidator;
  final ValueChanged<Country>? onCountryChanged;
  final List<Country> countries;
  final Country? initialCountry;

  const CountryPhoneInput({
    super.key,
    required this.controller,
    required this.countries,
    this.labelText = 'Phone Number',
    this.hintText = 'Enter your phone number',
    this.customValidator,
    this.onCountryChanged,
    this.initialCountry,
  });

  @override
  State<CountryPhoneInput> createState() => _CountryPhoneInputState();
}

class _CountryPhoneInputState extends State<CountryPhoneInput> {
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ??
        widget.countries.firstWhere(
              (c) => c.code == 'US',
          orElse: () => widget.countries.first,
        );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CountryPickerSheet(
        countries: widget.countries,
        selectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            _selectedCountry = country;
            // Clear the phone number when country changes
            widget.controller.clear();
          });
          widget.onCountryChanged?.call(country);
          Navigator.pop(context);
        },
      ),
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final rule = PhoneValidationRules.getRule(_selectedCountry.code);

    if (rule != null) {
      if (digitsOnly.length != rule.length) {
        return 'Phone number must be ${rule.length} digits for ${_selectedCountry.name}';
      }
    } else {
      if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        return 'Please enter a valid phone number';
      }
    }

    return widget.customValidator?.call(value);
  }

  String _getHintText() {
    final rule = PhoneValidationRules.getRule(_selectedCountry.code);
    if (rule != null) {
      // Replace X with placeholder digits
      return rule.format.replaceAll('X', '0');
    }
    return widget.hintText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: _getHintText(),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _showCountryPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedCountry.dialCode,
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.only(right: 12),
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.green.shade600,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        PhoneNumberFormatter(_selectedCountry.code),
      ],
      validator: _validatePhone,
    );
  }
}

class CountryPickerSheet extends StatefulWidget {
  final List<Country> countries;
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  const CountryPickerSheet({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  late List<Country> _filteredCountries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries;
      } else {
        _filteredCountries = widget.countries
            .where((country) =>
        country.name.toLowerCase().contains(query.toLowerCase()) ||
            country.dialCode.contains(query) ||
            country.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterCountries,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.green.shade600,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected = country.code == widget.selectedCountry.code;

                  return ListTile(
                    leading: Text(
                      country.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(country.name),
                    trailing: Text(
                      country.dialCode,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Colors.green.withOpacity(0.1),
                    onTap: () => widget.onCountrySelected(country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}