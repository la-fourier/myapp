import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleDriveService {
  final _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
  drive.DriveApi? _driveApi;

  Future<void> connect() async {
    final account = await _googleSignIn.signIn();
    final auth = await account!.authentication;

    final client = AuthenticatedClient(http.Client(), auth.accessToken!);
    _driveApi = drive.DriveApi(client);
  }

  Future<void> uploadJson(String fileName, Map<String, dynamic> data) async {
    if (_driveApi == null) throw Exception("Nicht verbunden mit Google Drive");

    final media = drive.Media(
      Stream.value(utf8.encode(jsonEncode(data))),
      utf8.encode(jsonEncode(data)).length,
      contentType: 'application/json',
    );

    final file = drive.File()
      ..name = fileName
      ..mimeType = 'application/json';

    await _driveApi!.files.create(file, uploadMedia: media);
  }

  Future<Map<String, dynamic>?> downloadJson(String fileName) async {
    final files = await _driveApi!.files.list(q: "name='$fileName'");
    if (files.files?.isEmpty ?? true) return null;

    final fileId = files.files!.first.id!;
    final media = await _driveApi!.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final data = await media.stream.toString();
    return jsonDecode(data);
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
