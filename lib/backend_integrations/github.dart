import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GitHubService {
  String? _accessToken;

  Future<void> connect() async {
    final clientId = 'YOUR_GITHUB_CLIENT_ID';
    final clientSecret = 'YOUR_GITHUB_CLIENT_SECRET';
    final redirectUrl = 'myapp://callback';

    final result = await FlutterWebAuth2.authenticate(
      url: 'https://github.com/login/oauth/authorize?client_id=$clientId&scope=gist',
      callbackUrlScheme: 'myapp',
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

  Future<Map<String, dynamic>?> downloadJson(String gistId, String fileName) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/gists/$gistId'),
      headers: {'Authorization': 'token $_accessToken'},
    );
    final json = jsonDecode(response.body);
    final content = json['files'][fileName]['content'];
    return jsonDecode(content);
  }
}
