import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier(ref.read(authServiceProvider));
});

class AuthStateNotifier extends StateNotifier<bool> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(false) {
    _init();
  }

  Future<void> _init() async {
    state = await _authService.isLoggedIn();
  }

  Future<String?> login(String email, String password) async {
    try {
      final tokens = await _authService.login(email, password);
      await _authService.saveTokens(tokens);
      state = true;
      await _seedDefaultCategories();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String email, String password, String firstName) async {
    try {
      await _authService.register(email, password, firstName);
      final loginError = await login(email, password);
      if (loginError == null) {
        await _seedDefaultCategories();
      }
      return loginError;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _seedDefaultCategories() async {
    final expenseService = ExpenseService();
    final incomeService = IncomeService();

    try {
      final existingExpenseCats = await expenseService.getCategories();
      if (existingExpenseCats.isEmpty) {
        final defaultExpenseCats = [
          {'name': 'Food & Dining', 'color': '#C2483F', 'icon': 'ti-cash'},
          {'name': 'Transport', 'color': '#3F7FC2', 'icon': 'ti-cash'},
          {'name': 'Rent & Housing', 'color': '#1D8763', 'icon': 'ti-cash'},
          {'name': 'Utilities', 'color': '#B8862F', 'icon': 'ti-cash'},
          {'name': 'Entertainment', 'color': '#8B5CF6', 'icon': 'ti-cash'},
          {'name': 'Healthcare', 'color': '#EC4899', 'icon': 'ti-cash'},
          {'name': 'Education', 'color': '#0EA5E9', 'icon': 'ti-cash'},
          {'name': 'Shopping', 'color': '#F97316', 'icon': 'ti-cash'},
          {'name': 'Other', 'color': '#6366F1', 'icon': 'ti-cash'},
        ];
        for (final cat in defaultExpenseCats) {
          await expenseService.createCategory(cat);
        }
      }
    } catch (_) {}

    try {
      final existingIncomeCats = await incomeService.getCategories();
      if (existingIncomeCats.isEmpty) {
        final defaultIncomeCats = [
          {'name': 'Salary', 'color': '#1D8763', 'icon': 'ti-cash'},
          {'name': 'Freelance', 'color': '#3F7FC2', 'icon': 'ti-cash'},
          {'name': 'Investment', 'color': '#B8862F', 'icon': 'ti-cash'},
          {'name': 'Business', 'color': '#8B5CF6', 'icon': 'ti-cash'},
          {'name': 'Gifts', 'color': '#EC4899', 'icon': 'ti-cash'},
          {'name': 'Other Income', 'color': '#6366F1', 'icon': 'ti-cash'},
        ];
        for (final cat in defaultIncomeCats) {
          await incomeService.createCategory(cat);
        }
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await _authService.logout();
    state = false;
  }
}
