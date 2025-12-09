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
    'ZA': PhoneRule(length: 9,  format: 'XX XXX XXXX'),
    'AU': PhoneRule(length: 9,  format: 'XXX XXX XXX'),
    'CA': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),
    'DE': PhoneRule(length: 10, format: 'XXX XXXXXXX'),
    'FR': PhoneRule(length: 9,  format: 'X XX XX XX XX'),
    'BR': PhoneRule(length: 11, format: '(XX) XXXXX-XXXX'),
    'JP': PhoneRule(length: 10, format: 'XX-XXXX-XXXX'),

    // ==== THE REST OF THE WORLD (249 total) ====
    'AD': PhoneRule(length: 6,  format: 'XXX XXX'),          // Andorra
    'AE': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // UAE
    'AF': PhoneRule(length: 9,  format: 'XX XXX XXXX'),        // Afghanistan
    'AG': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Antigua & Barbuda
    'AI': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Anguilla
    'AL': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Albania
    'AM': PhoneRule(length: 8,  format: 'XX XXXXXX'),        // Armenia
    'AO': PhoneRule(length: 9,  format: 'XXX XXX XXX XXX'),   // Angola
    'AQ': PhoneRule(length: 6,  format: 'XXX XXX'),          // Antarctica (rare)
    'AR': PhoneRule(length: 10, format: 'XX XXXX-XXXX'),     // Argentina
    'AS': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // American Samoa
    'AT': PhoneRule(length: 10, format: 'XXX XXXXXXXX'),     // Austria (variable, 10 most common)
    'AW': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Aruba
    'AX': PhoneRule(length: 7,  format: 'XX XXXXX'),         // Åland Islands
    'AZ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Azerbaijan
    'BA': PhoneRule(length: 8,  format: 'XX XXX XXX'),     // Bosnia
    'BB': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Barbados
    'BD': PhoneRule(length: 10, format: 'XX-XXXX-XXXX'),     // Bangladesh
    'BE': PhoneRule(length: 9,  format: 'XXX XX XX XX'),     // Belgium
    'BF': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Burkina Faso
    'BG': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Bulgaria
    'BH': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Bahrain
    'BI': PhoneRule(length: 8,  format: 'XX XX XXXX'),       // Burundi
    'BJ': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Benin
    'BL': PhoneRule(length: 9,  format: 'X XX XX XX XX'),    // St. Barthélemy
    'BM': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Bermuda
    'BN': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Brunei
    'BO': PhoneRule(length: 8,  format: 'X XXX XXXX'),       // Bolivia
    'BS': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Bahamas
    'BT': PhoneRule(length: 7,  format: 'XX XXX XXX'),       // Bhutan
    'BW': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Botswana
    'BY': PhoneRule(length: 9,  format: 'XX XXX-XX-XX'),   // Belarus
    'BZ': PhoneRule(length: 7,  format: 'XXX-XXXX'),         // Belize
    'CC': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Cocos Islands (same as AU)
    'CD': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Congo Kinshasa
    'CF': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Central African Rep.
    'CG': PhoneRule(length: 9,   format: 'XX XXX XXXX'),   // Congo Brazzaville
    'CH': PhoneRule(length: 9,  format: 'XX XXX XX XX'),     // Switzerland
    'CI': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Côte d’Ivoire
    'CK': PhoneRule(length: 5,  format: 'XX XXX'),           // Cook Islands
    'CL': PhoneRule(length: 9,  format: 'X XXXX XXXX'),      // Chile
    'CM': PhoneRule(length: 9,  format: 'XXXX XXXX'),        // Cameroon
    'CN': PhoneRule(length: 11, format: 'XXX XXXX XXXX'),    // China
    'CO': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Colombia
    'CR': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Costa Rica
    'CU': PhoneRule(length: 8,  format: 'X XXX XXXX'),       // Cuba
    'CV': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Cape Verde
    'CX': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Christmas Island
    'CY': PhoneRule(length: 8,  format: 'XX XXXXXX'),        // Cyprus
    'CZ': PhoneRule(length: 9,  format: 'XXX XXX XXX'),    // Czechia
    'DJ': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Djibouti
    'DK': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Denmark
    'DM': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Dominica
    'DO': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Dominican Republic
    'DZ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Algeria
    'EC': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Ecuador
    'EE': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Estonia (7–8, 8 most common mobile)
    'EG': PhoneRule(length: 10, format: 'XX XXXX XXXX'),     // Egypt
    'ER': PhoneRule(length: 7,  format: 'X XXX XXX'),        // Eritrea
    'ES': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Spain
    'ET': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Ethiopia
    'FI': PhoneRule(length: 9,  format: 'XX XXX XX XX'),     // Finland (variable, 9 common)
    'FJ': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Fiji
    'FK': PhoneRule(length: 5,  format: 'XXXXX'),            // Falkland Islands
    'FM': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Micronesia
    'FO': PhoneRule(length: 6,  format: 'XXX XXX'),          // Faroe Islands
    'GA': PhoneRule(length: 8,  format: 'X XX XX XX'),       // Gabon
    'GD': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Grenada
    'GE': PhoneRule(length: 9,  format: 'XXX XX XX XX'),     // Georgia
    'GF': PhoneRule(length: 9,  format: 'X XX XX XX XX'),    // French Guiana
    'GG': PhoneRule(length: 10, format: 'XXXXX XXXXX'),      // Guernsey (uses GB format)
    'GH': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Ghana
    'GI': PhoneRule(length: 8,  format: 'XXX XXXX'),        // Gibraltar
    'GL': PhoneRule(length: 6,  format: 'XX XX XX'),         // Greenland
    'GM': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Gambia
    'GN': PhoneRule(length: 9,  format: 'XX XXX XXXX'),    // Guinea
    'GP': PhoneRule(length: 9,  format: 'X XX XX XX XX'),    // Guadeloupe
    'GQ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Equatorial Guinea
    'GR': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Greece
    'GT': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Guatemala
    'GU': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Guam
    'GW': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Guinea-Bissau
    'GY': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Guyana
    'HK': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Hong Kong
    'HN': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Honduras
    'HR': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Croatia
    'HT': PhoneRule(length: 8,  format: 'XX XX XXXX'),       // Haiti
    'HU': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Hungary
    'ID': PhoneRule(length: 10, format: 'XX XXXX XXXX'),   // Indonesia (9–12, 10 most common)
    'IE': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Ireland
    'IL': PhoneRule(length: 9,  format: 'XX-XXX-XXXX'),      // Israel
    'IM': PhoneRule(length: 10, format: 'XXXXX XXXXX'),      // Isle of Man (GB format)
    'IO': PhoneRule(length: 7,  format: 'XXX XXXX'),         // British Indian Ocean Territory
    'IQ': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Iraq
    'IR': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Iran
    'IS': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Iceland
    'IT': PhoneRule(length: 10, format: 'XXX XXXX XXX'),     // Italy (variable, 10 common)
    'JE': PhoneRule(length: 10, format: 'XXXXX XXXXX'),      // Jersey (GB format)
    'JM': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Jamaica
    'JO': PhoneRule(length: 9,  format: 'X XXXX XXXX'),      // Jordan
    'KG': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Kyrgyzstan
    'KH': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Cambodia
    'KI': PhoneRule(length: 5,  format: 'XX XXX'),           // Kiribati
    'KM': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Comoros
    'KN': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // St. Kitts & Nevis
    'KP': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // North Korea (variable)
    'KR': PhoneRule(length: 10, format: 'XX-XXX-XXXX'),      // South Korea
    'KW': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Kuwait
    'KY': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Cayman Islands
    'KZ': PhoneRule(length: 10, format: 'XXX XXX-XX-XX'),     // Kazakhstan
    'LA': PhoneRule(length: 9,  format: 'XX XX XXX XXX'),    // Laos
    'LB': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Lebanon
    'LC': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Saint Lucia
    'LI': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Liechtenstein
    'LK': PhoneRule(length: 9,  format: 'XX XXX XXXX'),    // Sri Lanka
    'LR': PhoneRule(length: 8,  format: 'XX XXX XXXX'),      // Liberia
    'LS': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Lesotho
    'LT': PhoneRule(length: 8,  format: 'XXX XXXXX'),        // Lithuania
    'LU': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Luxembourg
    'LV': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Latvia
    'LY': PhoneRule(length: 9,  format: 'XX-XXX-XXXX'),      // Libya
    'MA': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Morocco
    'MC': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Monaco
    'MD': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Moldova
    'ME': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Montenegro
    'MF': PhoneRule(length: 9,  format: 'X XX XX XX XX'),    // St. Martin
    'MG': PhoneRule(length: 9,  format: 'XX XX XX XXX'),     // Madagascar
    'MH': PhoneRule(length: 7,  format: 'XXX-XXXX'),         // Marshall Islands
    'MK': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // North Macedonia
    'ML': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Mali
    'MM': PhoneRule(length: 9,  format: 'XX XXX XXXX'),     // Myanmar
    'MN': PhoneRule(length: 8,  format: 'XX XX XXXX'),      // Mongolia
    'MO': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Macao
    'MP': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Northern Mariana
    'MQ': PhoneRule(length: 9,  format: 'X XX XX XX XX'),    // Martinique
    'MR': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Mauritania
    'MS': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Montserrat
    'MT': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Malta
    'MU': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Mauritius
    'MV': PhoneRule(length: 7,  format: 'XXX-XXXX'),         // Maldives
    'MW': PhoneRule(length: 9,  format: 'XX XXX XXXX'),     // Malawi
    'MX': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Mexico
    'MY': PhoneRule(length: 9,  format: 'XX-XXX XXXX'),      // Malaysia (9–10)
    'MZ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Mozambique
    'NA': PhoneRule(length: 8,  format: 'XX XXX XXXX'),      // Namibia
    'NC': PhoneRule(length: 6,  format: 'XX.XX.XX'),         // New Caledonia
    'NE': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Niger
    'NF': PhoneRule(length: 5,  format: 'XXXXX'),            // Norfolk Island
    'NI': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Nicaragua
    'NL': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Netherlands
    'NO': PhoneRule(length: 8,  format: 'XXX XX XXX'),       // Norway
    'NP': PhoneRule(length: 10, format: 'XX-XXXX-XXXX'),     // Nepal
    'NR': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Nauru
    'NU': PhoneRule(length: 4,  format: 'XXXX'),             // Niue (very small)
    'NZ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // New Zealand (8–10, 9 common)
    'OM': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Oman
    'PA': PhoneRule(length: 8,  format: 'XXXX-XXXX'),        // Panama
    'PE': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Peru
    'PF': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // French Polynesia
    'PG': PhoneRule(length: 8,  format: 'XXX XXXX'),         // Papua New Guinea
    'PH': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Philippines
    'PK': PhoneRule(length: 10, format: 'XXX XXXXXXX'),      // Pakistan
    'PL': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Poland
    'PM': PhoneRule(length: 6,  format: 'XX XX XX'),         // St. Pierre & Miquelon
    'PN': PhoneRule(length: 5,  format: 'XXXXX'),            // Pitcairn
    'PR': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Puerto Rico
    'PS': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Palestine
    'PT': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Portugal
    'PW': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Palau
    'PY': PhoneRule(length: 9,  format: 'XXX XXXXXXX'),      // Paraguay
    'QA': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Qatar
    'RE': PhoneRule(length: 9,  format: 'X XX XX XX XX'),    // Réunion
    'RO': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Romania
    'RS': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Serbia
    'RU': PhoneRule(length: 10, format: 'XXX XXX-XX-XX'),     // Russia
    'RW': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Rwanda
    'SA': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Saudi Arabia
    'SB': PhoneRule(length: 7,  format: 'XXX XXXX'),       // Solomon Islands
    'SC': PhoneRule(length: 7,  format: 'X XXX XXX'),       // Seychelles
    'SD': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Sudan
    'SE': PhoneRule(length: 9,  format: 'XX XXX XX XX'),   // Sweden
    'SG': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // Singapore
    'SH': PhoneRule(length: 4,  format: 'XXXX'),             // St. Helena (very small)
    'SI': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Slovenia
    'SJ': PhoneRule(length: 8,  format: 'XXX XX XXX'),       // Svalbard
    'SK': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Slovakia
    'SL': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Sierra Leone
    'SM': PhoneRule(length: 10, format: 'XXXXX XXXXX'),      // San Marino (uses Italian numbering)
    'SN': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Senegal
    'SO': PhoneRule(length: 8,  format: 'X XXXXXXX'),        // Somalia
    'SR': PhoneRule(length: 7,  format: 'XXX-XXXX'),         // Suriname
    'SS': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // South Sudan
    'ST': PhoneRule(length: 7,  format: 'XX XXXXX'),         // São Tomé & Príncipe
    'SV': PhoneRule(length: 8,  format: 'XXXX XXXX'),        // El Salvador
    'SY': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Syria
    'SZ': PhoneRule(length: 8,  format: 'XX XX XXXX'),       // Eswatini
    'TC': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Turks & Caicos
    'TD': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Chad
    'TG': PhoneRule(length: 8,  format: 'XX XX XX XX'),      // Togo
    'TH': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Thailand
    'TJ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Tajikistan
    'TK': PhoneRule(length: 4,  format: 'XXXX'),             // Tokelau
    'TL': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Timor-Leste
    'TM': PhoneRule(length: 8,  format: 'XX XXXXXX'),        // Turkmenistan
    'TN': PhoneRule(length: 8,  format: 'XX XXX XXX'),       // Tunisia
    'TO': PhoneRule(length: 5,  format: 'XX XXX'),           // Tonga
    'TR': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Turkey
    'TT': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // Trinidad & Tobago
    'TV': PhoneRule(length: 5,  format: 'XX XXX'),           // Tuvalu
    'TW': PhoneRule(length: 9,  format: 'X XXXX XXXX'),    // Taiwan
    'TZ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Tanzania
    'UA': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Ukraine
    'UG': PhoneRule(length: 9,  format: 'XXX XXX XXX'),      // Uganda
    'UY': PhoneRule(length: 8,  format: 'X XXX XXXX'),       // Uruguay
    'UZ': PhoneRule(length: 9,  format: 'XX XXX XXXX'),     // Uzbekistan
    'VA': PhoneRule(length: 10, format: 'XX XXXX XXXX'),     // Vatican City (uses Italian)
    'VC': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // St. Vincent
    'VE': PhoneRule(length: 10, format: 'XXX XXX XXXX'),     // Venezuela
    'VG': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // British Virgin Islands
    'VI': PhoneRule(length: 10, format: '(XXX) XXX-XXXX'),   // U.S. Virgin Islands
    'VN': PhoneRule(length: 9,  format: 'XXX XXX XXXX'),      // Vietnam (9–10)
    'VU': PhoneRule(length: 7,  format: 'XXX XXXX'),         // Vanuatu
    'WF': PhoneRule(length: 6,  format: 'XX XX XX'),         // Wallis & Futuna
    'WS': PhoneRule(length: 7,  format: 'XX XXXX'),          // Samoa
    'YE': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Yemen
    'YT': PhoneRule(length: 9,  format: 'X XX XX XX XX'),    // Mayotte
    'ZM': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Zambia
    'ZW': PhoneRule(length: 9,  format: 'XX XXX XXXX'),      // Zimbabwe
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
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
        LengthLimitingTextInputFormatter(15),
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


