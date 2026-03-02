import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GitHubService {
  String? _accessToken;
  final _storage = const FlutterSecureStorage();

  Future<void> connect() async {
    final clientId = await _storage.read(key: 'github_client_id');
    final clientSecret = await _storage.read(key: 'github_client_secret');

    if (clientId == null || clientId.isEmpty || clientSecret == null || clientSecret.isEmpty) {
      throw Exception("GitHub Client ID or Secret is not configured. Please set them in your Account Integrations.");
    }

    // The callbackUrlScheme is a required parameter.
    // For mobile, it's the custom scheme you've registered (e.g., 'myapp').
    // For web, this value is not used for the redirect, but a non-empty
    // string is required by the library. The actual redirect URL is configured
    // in your GitHub OAuth App settings.
    final callbackUrlScheme = kIsWeb ? 'app' : 'myapp';

    final result = await FlutterWebAuth2.authenticate(
      url:
          'https://github.com/login/oauth/authorize?client_id=$clientId&scope=gist',
      callbackUrlScheme: callbackUrlScheme,
    );

    final code = Uri.parse(result).queryParameters['code'];
    final response = await http.post(
      Uri.parse('https://github.com/login/oauth/access_token'),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code!,
      },
    );
    _accessToken = jsonDecode(response.body)['access_token'];
  }

  Future<void> uploadJson(String fileName, Map<String, dynamic> data) async {
    if (_accessToken == null) throw Exception("Not connected to GitHub");

    final gist = {
      'description': 'App Backup',
      'public': false,
      'files': {
        fileName: {'content': jsonEncode(data)},
      },
    };

    await http.post(
      Uri.parse('https://api.github.com/gists'),
      headers: {
        'Authorization': 'token $_accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
      body: jsonEncode(gist),
    );
  }

  Future<Map<String, dynamic>?> downloadJson(
    String gistId,
    String fileName,
  ) async {
    if (_accessToken == null) throw Exception("Not connected to GitHub");

    final response = await http.get(
      Uri.parse('https://api.github.com/gists/$gistId'),
      headers: {'Authorization': 'token $_accessToken'},
    );
    final json = jsonDecode(response.body);
    final content = json['files'][fileName]['content'];
    return jsonDecode(content);
  }
}
