import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:myapp/models/calendar/appointment.dart';
import 'package:myapp/models/finance/bill.dart';
import 'package:myapp/models/person.dart';
// import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';

import 'package:myapp/services/app_state.dart';

class ExportService {
  Future<void> exportData(AppState appState, String format) async {
    final user = appState.loggedInUser;
    if (user == null) {
      throw Exception('No user is logged in.');
    }

    final Map<String, dynamic> data = {
      'user': user.person.toJson(),
      'contacts': user.contacts
          .map((Person person) => person.toJson())
          .toList(),
      'appointments': user.calendar.appointments
          .map((Appointment appointment) => appointment.toJson())
          .toList(),
      'bills': user.bills.map((Bill bill) => bill.toJson()).toList(),
    };

    String fileContent;
    String fileName;

    switch (format) {
      case "json":
        fileContent = json.encode(data);
        fileName = 'export.json';
        break;
      case "txt":
        fileContent = _toTxt(data);
        fileName = 'export.txt';
        break;
      case "csv":
        fileContent = _toCsv(data);
        fileName = 'export.csv';
        break;
      default:
        throw Exception('Unsupported export format: $format');
    }

    if (kIsWeb) {
      _downloadFile(fileContent, fileName);
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: fileName,
      );

      if (outputFile != null) {
        final File file = File(outputFile);
        await file.writeAsString(fileContent);
      }
    }
  }

  String _toTxt(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      buffer.writeln('--- $key ---');
      if (value is List) {
        for (var item in value) {
          buffer.writeln(item.toString());
        }
      } else {
        buffer.writeln(value.toString());
      }
      buffer.writeln();
    });
    return buffer.toString();
  }

  String _toCsv(Map<String, dynamic> data) {
    final List<List<dynamic>> csvData = [];
    data.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        final headers = (value.first as Map<String, dynamic>).keys.toList();
        csvData.add([key]);
        csvData.add(headers);
        for (var item in value) {
          csvData.add((item as Map<String, dynamic>).values.toList());
        }
        csvData.add([]); // Add empty line between sections
      }
    });
    return const ListToCsvConverter().convert(csvData);
  }

  void _downloadFile(String content, String fileName) {
    final bytes = utf8.encode(content);
    // final blob = html.Blob([bytes]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.AnchorElement(href: url)
    //   ..setAttribute("download", fileName)
    //   ..click();
    // html.Url.revokeObjectUrl(url);
  }
}
