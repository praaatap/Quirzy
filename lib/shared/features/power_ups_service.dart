import 'package:shared_preferences/shared_preferences.dart';

/// Feature 7: Power-ups System
/// 50/50, Freeze Timer, Second Chance shields
class PowerUpsService {
  static PowerUpsService? _instance;
  
  static const String _fiftyFiftyKey = 'powerup_5050';
  static const String _freezeKey = 'powerup_freeze';
  static const String _shieldKey = 'powerup_shield';

  factory PowerUpsService() {
    _instance ??= PowerUpsService._internal();
    return _instance!;
  }

  PowerUpsService._internal();

  /// Get current power-up counts
  Future<PowerUpInventory> getInventory() async {
    final prefs = await SharedPreferences.getInstance();
    return PowerUpInventory(
      fiftyFifty: prefs.getInt(_fiftyFiftyKey) ?? 3,
      freeze: prefs.getInt(_freezeKey) ?? 2,
      shield: prefs.getInt(_shieldKey) ?? 1,
    );
  }

  /// Use 50/50 power-up (removes 2 wrong answers)
  Future<bool> useFiftyFifty() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_fiftyFiftyKey) ?? 3;
    
    if (count <= 0) return false;
    
    count--;
    await prefs.setInt(_fiftyFiftyKey, count);
    return true;
  }

  /// Use Freeze power-up (stops timer)
  Future<bool> useFreeze() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_freezeKey) ?? 2;
    
    if (count <= 0) return false;
    
    count--;
    await prefs.setInt(_freezeKey, count);
    return true;
  }

  /// Use Shield power-up (second chance)
  Future<bool> useShield() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_shieldKey) ?? 1;
    
    if (count <= 0) return false;
    
    count--;
    await prefs.setInt(_shieldKey, count);
    return true;
  }

  /// Add power-ups (from rewards/purchases)
  Future<void> addPowerUps({int fiftyFifty = 0, int freeze = 0, int shield = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (fiftyFifty > 0) {
      final current = prefs.getInt(_fiftyFiftyKey) ?? 3;
      await prefs.setInt(_fiftyFiftyKey, current + fiftyFifty);
    }
    
    if (freeze > 0) {
      final current = prefs.getInt(_freezeKey) ?? 2;
      await prefs.setInt(_freezeKey, current + freeze);
    }
    
    if (shield > 0) {
      final current = prefs.getInt(_shieldKey) ?? 1;
      await prefs.setInt(_shieldKey, current + shield);
    }
  }

  /// Reset power-ups to default (daily)
  Future<void> resetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fiftyFiftyKey, 3);
    await prefs.setInt(_freezeKey, 2);
    await prefs.setInt(_shieldKey, 1);
  }
}

class PowerUpInventory {
  final int fiftyFifty;
  final int freeze;
  final int shield;

  const PowerUpInventory({
    required this.fiftyFifty,
    required this.freeze,
    required this.shield,
  });

  bool get hasAny => fiftyFifty > 0 || freeze > 0 || shield > 0;
}
