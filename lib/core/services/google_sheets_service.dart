import 'dart:io';
import 'package:mybot/core/services/env_service.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsScope];

  final SheetsApi _sheetsApi;
  final String spreadsheetId;

  GoogleSheetsService._(this._sheetsApi, this.spreadsheetId);

  static Future<GoogleSheetsService> create() async {
    final credentialsPath = EnvService.get("GOOGLE_CREDENTIALS_PATH");
    final jsonCredentials = await File(credentialsPath).readAsString();

    final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);
    final authClient = await clientViaServiceAccount(credentials, _scopes);
    final sheetsApi = SheetsApi(authClient);

    final spreadsheetId = EnvService.get('SPREEDSHEET_ID');
    if (spreadsheetId == null || spreadsheetId.isEmpty) {
      throw Exception('Spreadsheet ID is not set in .env');
    }

    return GoogleSheetsService._(sheetsApi, spreadsheetId);
  }

  Future<List<String>> listSheets() async {
    final spreadsheet = await _sheetsApi.spreadsheets.get(spreadsheetId);
    return spreadsheet.sheets?.map((s) => s.properties!.title!).toList() ?? [];
  }

  Future<List<String>> getColumnNames(String sheetName) async {
    final range = '$sheetName!1:1';
    final response = await _sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      range,
    );
    final row = response.values?.first ?? [];
    return List<String>.from(row);
  }

  Future<void> appendRow(String sheetName, List<String> values) async {
    final range = '$sheetName';
    final valueRange = ValueRange(values: [values]);

    await _sheetsApi.spreadsheets.values.append(
      valueRange,
      spreadsheetId,
      range,
      valueInputOption: 'USER_ENTERED',
    );
  }
}
