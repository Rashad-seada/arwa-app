import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_package/core/services/supabase_database.dart';

// Provider for the Supabase database service
final databaseProvider = Provider<SupabaseDatabase>((ref) {
  return SupabaseDatabase();
}); 