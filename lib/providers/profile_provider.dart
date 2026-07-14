import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_service.dart';

final profileServiceProvider = Provider((ref) => ProfileService());

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(profileServiceProvider);
  return service.getProfile();
});
