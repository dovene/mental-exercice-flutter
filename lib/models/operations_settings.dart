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
      'selectedNumber': selectedNumber,
      'waitingTime': waitingTime,
      'isHardMode': isHardMode,
      'simpleMode': simpleMode,
      'multiDigitMode': multiDigitMode,
      'decimalMode': decimalMode,
    };
  }

  // Pour charger depuis SharedPreferences
  static OperationSettings fromMap(Map<String, dynamic> map) {
    return OperationSettings(
      selectedNumber: map['selectedNumber'] ?? 0,
      waitingTime: map['waitingTime'] ?? 5,
      isHardMode: map['isHardMode'] ?? false,
      simpleMode: map['simpleMode'] ?? true,
      multiDigitMode: map['multiDigitMode'] ?? false,
      decimalMode: map['decimalMode'] ?? false,
    );
  }
}