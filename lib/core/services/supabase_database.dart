import 'dart:typed_data';
import 'package:flutter_starter_package/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabase {
  final _supabase = SupabaseConfig.client;
  
  // Generic method to fetch data from any table
  Future<List<Map<String, dynamic>>> getAll(String tableName, {
    int? limit,
    int? offset,
    String? orderBy,
    bool ascending = true,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Start with a base query
      dynamic query = _supabase.from(tableName).select();
      
      // Apply filters if provided
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }
      
      // Apply ordering if provided
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      // Apply pagination if provided
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }
      
      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Failed to fetch data: ${e.toString()}');
    }
  }
  
  // Get a single record by ID
  Future<Map<String, dynamic>> getById(String tableName, String id) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .eq('id', id)
          .single();
      
      return data;
    } catch (e) {
      throw Exception('Failed to fetch record: ${e.toString()}');
    }
  }
  
  // Insert a new record
  Future<Map<String, dynamic>> insert(String tableName, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to insert record: ${e.toString()}');
    }
  }
  
  // Update a record
  Future<Map<String, dynamic>> update(String tableName, String id, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to update record: ${e.toString()}');
    }
  }
  
  // Delete a record
  Future<void> delete(String tableName, String id) async {
    try {
      await _supabase
          .from(tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete record: ${e.toString()}');
    }
  }
  
  // Upsert (insert or update) a record
  Future<Map<String, dynamic>> upsert(String tableName, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .upsert(data)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to upsert record: ${e.toString()}');
    }
  }
  
  // Execute a raw SQL query (use with caution)
  Future<List<Map<String, dynamic>>> rawQuery(String query, List<dynamic> params) async {
    try {
      final response = await _supabase.rpc(
        'execute_sql',
        params: {
          'query_text': query,
          'params': params,
        },
      );
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to execute query: ${e.toString()}');
    }
  }
  
  // Real-time subscription to changes in a table
  RealtimeChannel subscribeToTable(String tableName, {
    required void Function(Map<String, dynamic>) onInsert,
    required void Function(Map<String, dynamic>) onUpdate,
    required void Function(Map<String, dynamic>) onDelete,
  }) {
    try {
      final channel = _supabase
          .channel('public:$tableName')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: tableName,
            callback: (payload) {
              onInsert(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: tableName,
            callback: (payload) {
              onUpdate(payload.newRecord);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: tableName,
            callback: (payload) {
              onDelete(payload.oldRecord);
            },
          );
          
      channel.subscribe();
      return channel;
    } catch (e) {
      throw Exception('Failed to subscribe to table changes: ${e.toString()}');
    }
  }
  
  // Storage operations
  Future<String> uploadFile(String bucket, String path, List<int> fileBytes, String contentType) async {
    try {
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        Uint8List.fromList(fileBytes),
        fileOptions: FileOptions(contentType: contentType),
      );
      
      final String fileUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      return fileUrl;
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }
  
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }
  
  String getPublicUrl(String bucket, String path) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }
} 