import 'dart:io';
import 'package:mybot/core/constants/role_enum.dart';
import 'package:mybot/core/services/env_service.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsScope];

  final SheetsApi _sheetsApi;
  final String spreadsheetId;
  final String logsSpreadsheetId;

  GoogleSheetsService._(
    this._sheetsApi,
    this.spreadsheetId,
    this.logsSpreadsheetId,
  );

  static Future<GoogleSheetsService> create() async {
    final credentialsPath = EnvService.get("GOOGLE_CREDENTIALS_PATH");
    final jsonCredentials = await File(credentialsPath).readAsString();

    final credentials = ServiceAccountCredentials.fromJson(jsonCredentials);
    final authClient = await clientViaServiceAccount(credentials, _scopes);
    final sheetsApi = SheetsApi(authClient);

    final spreadsheetId = EnvService.get('SPREEDSHEET_ID');
    final logsSpreadsheetId = EnvService.get('SPREEDSHEET_LOGS_ID');

    if (spreadsheetId == null || spreadsheetId.isEmpty) {
      throw Exception('SPREEDSHEET_ID is not set in .env');
    }

    if (logsSpreadsheetId == null || logsSpreadsheetId.isEmpty) {
      throw Exception('SPREEDSHEET_LOGS_ID is not set in .env');
    }

    return GoogleSheetsService._(sheetsApi, spreadsheetId, logsSpreadsheetId);
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
      ValueRange(values: [values]),
      logsSpreadsheetId,
      'Logs!A:E',
      valueInputOption: 'USER_ENTERED',
    );
  }

  Future<List<List<String>>> getTodayLogs() async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final result = await _sheetsApi.spreadsheets.values.get(
      logsSpreadsheetId,
      'Logs!A:E',
    );

    final rows = result.values ?? [];
    return rows
        .where((row) => row.length >= 4 && row[3] == today)
        .map((row) => row.map((e) => e?.toString() ?? '').toList())
        .toList();
  }

  Future<void> inputRoleAdmin({
    required String role,
    required String userName,
    required int userId,
  }) async {
    final values = [role, '@$userName', userId.toString()];
    await _sheetsApi.spreadsheets.values.append(
      ValueRange(values: [values]),
      logsSpreadsheetId,
      'Roles!A:C',
      valueInputOption: 'USER_ENTERED',
    );
  }

  Future<void> logSilently({
    required String userName,
    required String role,
    required String action,
  }) async {
    try {
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final values = [userName, role, action, date, time];

      await _sheetsApi.spreadsheets.values.append(
        ValueRange(values: [values]),
        logsSpreadsheetId,
        'Logs!A:E',
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      print('Ошибка при логировании: $e');
    }
  }

  Future<Map<int, RoleEnum>> loadRolesFromSheet() async {
    final result = await _sheetsApi.spreadsheets.values.get(
      logsSpreadsheetId,
      'Roles!A:C',
    );

    final rows = result.values ?? [];

    final roleMap = <int, RoleEnum>{};

    for (final row in rows.skip(1)) {
      // Пропускаем заголовок
      if (row.length < 3) continue;

      final roleStr = row[0]?.toString().trim().toLowerCase();
      final tgIdStr = row[2]?.toString().trim();

      final tgId = int.tryParse(tgIdStr ?? '');
      if (tgId == null) continue;

      if (roleStr == 'admin') {
        roleMap[tgId] = RoleEnum.admin;
      } else if (roleStr == 'super admin') {
        roleMap[tgId] = RoleEnum.superAdmin;
      }
    }

    return roleMap;
  }
}
