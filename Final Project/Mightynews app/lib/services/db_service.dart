import 'dart:io';
import 'package:postgres/postgres.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  PostgreSQLConnection? _connection;

  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && !_connection!.isClosed) return _connection!;
    return await _initDB();
  }

  Future<PostgreSQLConnection> _initDB() async {
    // 10.0.2.2 is for Android Emulator to see Localhost. 
    // Use 192.168.x.x for real devices.
    final dbHost = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';

    _connection = PostgreSQLConnection(
      dbHost,
      5432,
      'Mightynewsapp',
      username: 'postgres',
      password: '123abc',
    );

    await _connection!.open();
    return _connection!;
  }
}