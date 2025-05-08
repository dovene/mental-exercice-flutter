enum SettingName {
  selectedNumber,
  waitingTime,
  isHardMode,
  simpleMode,
  multiDigitMode,
  decimalMode,
}

class OperationSettings {
  int selectedNumber;
  int waitingTime;
  bool isHardMode;
  bool simpleMode; // Additions simples, soustractions simples, etc.
  bool multiDigitMode; // Opérations à plusieurs chiffres
  bool decimalMode; // Opérations avec décimaux

  OperationSettings({
    this.selectedNumber = 0,
    this.waitingTime = 5,
    this.isHardMode = false,
    this.simpleMode = true,
    this.multiDigitMode = false,
    this.decimalMode = false,
  });

  // Clone avec modification
  OperationSettings copyWith({
    int? selectedNumber,
    int? waitingTime,
    bool? isHardMode,
    bool? simpleMode,
    bool? multiDigitMode,
    bool? decimalMode,
  }) {
    return OperationSettings(
      selectedNumber: selectedNumber ?? this.selectedNumber,
      waitingTime: waitingTime ?? this.waitingTime,
      isHardMode: isHardMode ?? this.isHardMode,
      simpleMode: simpleMode ?? this.simpleMode,
      multiDigitMode: multiDigitMode ?? this.multiDigitMode,
      decimalMode: decimalMode ?? this.decimalMode,
    );
  }

  // Pour sauvegarder dans SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      SettingName.selectedNumber.name: selectedNumber,
      SettingName.waitingTime.name: waitingTime,
      SettingName.isHardMode.name: isHardMode,
      SettingName.simpleMode.name: simpleMode,
      SettingName.multiDigitMode.name: multiDigitMode,
      SettingName.decimalMode.name: decimalMode,
    };
  }

  // Pour charger depuis SharedPreferences
  static OperationSettings fromMap(Map<String, dynamic> map) {
    return OperationSettings(
      selectedNumber: map[SettingName.selectedNumber.name] ?? 0,
      waitingTime: map[SettingName.waitingTime.name] ?? 5,
      isHardMode: map[SettingName.isHardMode.name] ?? false,
      simpleMode: map[SettingName.simpleMode.name] ?? true,
      multiDigitMode: map[SettingName.multiDigitMode.name] ?? false,
      decimalMode: map[SettingName.decimalMode.name] ?? false,
    );
  }
}
