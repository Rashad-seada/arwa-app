import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../domain/models/eye_scan.dart';
import '../../domain/repositories/eye_scan_repository.dart';

class SupabaseEyeScanRepository implements EyeScanRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'eye_scans';
  final String _storageBucket = 'eye-scans';
  
  @override
  Future<List<EyeScan>> getEyeScans(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => EyeScan.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching eye scans: $e');
      throw Exception('Failed to fetch eye scans');
    }
  }

  @override
  Future<EyeScan> getEyeScanById(String scanId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', scanId)
          .single();
      
      return EyeScan.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching eye scan: $e');
      throw Exception('Failed to fetch eye scan');
    }
  }

  @override
  Future<EyeScan> createEyeScan(EyeScan scan) async {
    try {
      // Upload image to storage
      final File imageFile = File(scan.imagePath);
      final String fileExt = path.extension(scan.imagePath);
      final String fileName = '${const Uuid().v4()}$fileExt';
      final String storagePath = '${scan.userId}/$fileName';
      
      await _client.storage.from(_storageBucket).upload(
        storagePath,
        imageFile,
      );
      
      // Get public URL for the uploaded image
      final String imageUrl = _client.storage.from(_storageBucket).getPublicUrl(storagePath);
      
      // Create record in database
      final data = {
        ...scan.toJson(),
        'image_path': imageUrl,
      };
      
      final response = await _client
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      
      return EyeScan.fromJson(response);
    } catch (e) {
      debugPrint('Error creating eye scan: $e');
      throw Exception('Failed to create eye scan: $e');
    }
  }

  @override
  Future<EyeScan> updateEyeScan(EyeScan scan) async {
    try {
      await _client
          .from(_tableName)
          .update(scan.toJson())
          .eq('id', scan.id);
      
      return scan;
    } catch (e) {
      debugPrint('Error updating eye scan: $e');
      throw Exception('Failed to update eye scan');
    }
  }

  @override
  Future<void> deleteEyeScan(String scanId) async {
    try {
      // Get the scan first to get the image path
      final scan = await getEyeScanById(scanId);
      
      // Delete from database
      await _client
          .from(_tableName)
          .delete()
          .eq('id', scanId);
      
      // Extract storage path from URL
      final Uri uri = Uri.parse(scan.imagePath);
      final String storagePath = uri.path.replaceFirst('/storage/v1/object/public/$_storageBucket/', '');
      
      // Delete from storage
      await _client.storage.from(_storageBucket).remove([storagePath]);
    } catch (e) {
      debugPrint('Error deleting eye scan: $e');
      throw Exception('Failed to delete eye scan');
    }
  }
} 