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
    // FIX: Simple, clean check to avoid "variable already assigned" errors
    String dbHost = '127.0.0.1';
    
    try {
      if (Platform.isAndroid) {
        dbHost = '10.0.2.2';
      }
    } catch (e) {
      // Ignore platform errors (happens on some weird linux setups)
      dbHost = '127.0.0.1'; 
    }

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