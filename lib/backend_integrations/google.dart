import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  GoogleSignIn? _googleSignIn;
  drive.DriveApi? _driveApi;
  final _storage = const FlutterSecureStorage();

  Future<void> connect() async {
    // DUMMY IMPLEMENTATION: OAuth is not yet configured
    await Future.delayed(const Duration(seconds: 1));
    // We mock success, but leave _driveApi as null. 
    // The methods below will need dummy handling as well.
  }

  Future<void> uploadJson(String fileName, Map<String, dynamic> data) async {
    // DUMMY UPLOAD
    await Future.delayed(const Duration(milliseconds: 500));
    print('Dummy uploaded $fileName to Google Drive');
  }

  Future<Map<String, dynamic>?> downloadJson(String fileName) async {
    // DUMMY DOWNLOAD
    await Future.delayed(const Duration(milliseconds: 500));
    return {'dummy': 'data'};
  }
}

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final String _token;
  AuthenticatedClient(this._inner, this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }
}
