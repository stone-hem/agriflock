
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String baseUrl ='https://api.agriflock360.com/api/v1';
  static final String googleApiKey=dotenv.env['GOOGLE_API_KEY']!;

}