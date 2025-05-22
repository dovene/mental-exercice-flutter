// Updated OperationSettings class with operation type selections
enum SettingName {
  selectedNumber,
  waitingTime,
  isHardMode,
  simpleMode,
  multiDigitMode,
  decimalMode,
  includeAddition, // New settings for problem operations
  includeSubtraction,
  includeMultiplication,
  includeDivision,
}

class OperationSettings {
  int selectedNumber;
  int waitingTime;
  bool isHardMode;
  bool simpleMode; // Additions simples, soustractions simples, etc.
  bool multiDigitMode; // Opérations à plusieurs chiffres
  bool decimalMode; // Opérations avec décimaux

  // New properties for problem operations
  bool includeAddition; // Addition operations
  bool includeSubtraction; // Subtraction operations
  bool includeMultiplication; // Multiplication operations
  bool includeDivision; // Division operations

  OperationSettings({
    this.selectedNumber = 0,
    this.waitingTime = 5,
    this.isHardMode = false,
    this.simpleMode = true,
    this.multiDigitMode = false,
    this.decimalMode = false,
    // Default: include all operations
    this.includeAddition = true,
    this.includeSubtraction = false,
    this.includeMultiplication = false,
    this.includeDivision = false,
  });

  // Clone avec modification
  OperationSettings copyWith({
    int? selectedNumber,
    int? waitingTime,
    bool? isHardMode,
    bool? simpleMode,
    bool? multiDigitMode,
    bool? decimalMode,
    bool? includeAddition,
    bool? includeSubtraction,
    bool? includeMultiplication,
    bool? includeDivision,
  }) {
    return OperationSettings(
      selectedNumber: selectedNumber ?? this.selectedNumber,
      waitingTime: waitingTime ?? this.waitingTime,
      isHardMode: isHardMode ?? this.isHardMode,
      simpleMode: simpleMode ?? this.simpleMode,
      multiDigitMode: multiDigitMode ?? this.multiDigitMode,
      decimalMode: decimalMode ?? this.decimalMode,
      includeAddition: includeAddition ?? this.includeAddition,
      includeSubtraction: includeSubtraction ?? this.includeSubtraction,
      includeMultiplication:
          includeMultiplication ?? this.includeMultiplication,
      includeDivision: includeDivision ?? this.includeDivision,
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
      SettingName.includeAddition.name: includeAddition,
      SettingName.includeSubtraction.name: includeSubtraction,
      SettingName.includeMultiplication.name: includeMultiplication,
      SettingName.includeDivision.name: includeDivision,
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
      includeAddition: map[SettingName.includeAddition.name] ?? true,
      includeSubtraction: map[SettingName.includeSubtraction.name] ?? true,
      includeMultiplication:
          map[SettingName.includeMultiplication.name] ?? true,
      includeDivision: map[SettingName.includeDivision.name] ?? true,
    );
  }

  // Ensure at least one operation is selected
  bool hasAtLeastOneOperation() {
    return includeAddition ||
        includeSubtraction ||
        includeMultiplication ||
        includeDivision;
  }
}
