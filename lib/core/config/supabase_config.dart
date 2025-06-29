import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Replace with your Supabase URL and anon key
  static const String supabaseUrl = 'https://reycfewrzqskkrhpvous.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJleWNmZXdyenFza2tyaHB2b3VzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExNjk5MDIsImV4cCI6MjA2Njc0NTkwMn0.QeKJA8dXi1z3Aaz_MrsFF1Z2BKOHxr-Lvtm-nmzAZFw';
  
  // Singleton instance
  static final SupabaseClient client = Supabase.instance.client;
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false, // Set to true for development
    );
  }
} 