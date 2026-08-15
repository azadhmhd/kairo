// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kairo_database.dart';

// ignore_for_file: type=lint
class $ReminderDefinitionsTable extends ReminderDefinitions
    with TableInfo<$ReminderDefinitionsTable, ReminderDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderKind>($ReminderDefinitionsTable.$converterkind);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalSecondsMeta = const VerificationMeta(
    'intervalSeconds',
  );
  @override
  late final GeneratedColumn<int> intervalSeconds = GeneratedColumn<int>(
    'interval_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeFromMinuteMeta = const VerificationMeta(
    'activeFromMinute',
  );
  @override
  late final GeneratedColumn<int> activeFromMinute = GeneratedColumn<int>(
    'active_from_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeToMinuteMeta = const VerificationMeta(
    'activeToMinute',
  );
  @override
  late final GeneratedColumn<int> activeToMinute = GeneratedColumn<int>(
    'active_to_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    label,
    intervalSeconds,
    activeFromMinute,
    activeToMinute,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('interval_seconds')) {
      context.handle(
        _intervalSecondsMeta,
        intervalSeconds.isAcceptableOrUnknown(
          data['interval_seconds']!,
          _intervalSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalSecondsMeta);
    }
    if (data.containsKey('active_from_minute')) {
      context.handle(
        _activeFromMinuteMeta,
        activeFromMinute.isAcceptableOrUnknown(
          data['active_from_minute']!,
          _activeFromMinuteMeta,
        ),
      );
    }
    if (data.containsKey('active_to_minute')) {
      context.handle(
        _activeToMinuteMeta,
        activeToMinute.isAcceptableOrUnknown(
          data['active_to_minute']!,
          _activeToMinuteMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderDefinitionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $ReminderDefinitionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      intervalSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_seconds'],
      )!,
      activeFromMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_from_minute'],
      ),
      activeToMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_to_minute'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $ReminderDefinitionsTable createAlias(String alias) {
    return $ReminderDefinitionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderKind, String, String> $converterkind =
      const EnumNameConverter<ReminderKind>(ReminderKind.values);
}

class ReminderDefinitionRow extends DataClass
    implements Insertable<ReminderDefinitionRow> {
  /// Identifies the reminder.
  final String id;

  /// Which [ReminderKind] this is, stored by name so the column stays readable.
  final ReminderKind kind;

  /// What the user is shown when it fires.
  final String label;

  /// How long Kairo waits between firings, in seconds.
  final int intervalSeconds;

  /// The first minute of the day this may fire, or null for all day.
  final int? activeFromMinute;

  /// The minute of the day it stops firing, or null for all day.
  final int? activeToMinute;

  /// Whether the reminder is currently being made.
  final bool enabled;
  const ReminderDefinitionRow({
    required this.id,
    required this.kind,
    required this.label,
    required this.intervalSeconds,
    this.activeFromMinute,
    this.activeToMinute,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>(
        $ReminderDefinitionsTable.$converterkind.toSql(kind),
      );
    }
    map['label'] = Variable<String>(label);
    map['interval_seconds'] = Variable<int>(intervalSeconds);
    if (!nullToAbsent || activeFromMinute != null) {
      map['active_from_minute'] = Variable<int>(activeFromMinute);
    }
    if (!nullToAbsent || activeToMinute != null) {
      map['active_to_minute'] = Variable<int>(activeToMinute);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  ReminderDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return ReminderDefinitionsCompanion(
      id: Value(id),
      kind: Value(kind),
      label: Value(label),
      intervalSeconds: Value(intervalSeconds),
      activeFromMinute: activeFromMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(activeFromMinute),
      activeToMinute: activeToMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(activeToMinute),
      enabled: Value(enabled),
    );
  }

  factory ReminderDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderDefinitionRow(
      id: serializer.fromJson<String>(json['id']),
      kind: $ReminderDefinitionsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      label: serializer.fromJson<String>(json['label']),
      intervalSeconds: serializer.fromJson<int>(json['intervalSeconds']),
      activeFromMinute: serializer.fromJson<int?>(json['activeFromMinute']),
      activeToMinute: serializer.fromJson<int?>(json['activeToMinute']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $ReminderDefinitionsTable.$converterkind.toJson(kind),
      ),
      'label': serializer.toJson<String>(label),
      'intervalSeconds': serializer.toJson<int>(intervalSeconds),
      'activeFromMinute': serializer.toJson<int?>(activeFromMinute),
      'activeToMinute': serializer.toJson<int?>(activeToMinute),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  ReminderDefinitionRow copyWith({
    String? id,
    ReminderKind? kind,
    String? label,
    int? intervalSeconds,
    Value<int?> activeFromMinute = const Value.absent(),
    Value<int?> activeToMinute = const Value.absent(),
    bool? enabled,
  }) => ReminderDefinitionRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    activeFromMinute: activeFromMinute.present
        ? activeFromMinute.value
        : this.activeFromMinute,
    activeToMinute: activeToMinute.present
        ? activeToMinute.value
        : this.activeToMinute,
    enabled: enabled ?? this.enabled,
  );
  ReminderDefinitionRow copyWithCompanion(ReminderDefinitionsCompanion data) {
    return ReminderDefinitionRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      intervalSeconds: data.intervalSeconds.present
          ? data.intervalSeconds.value
          : this.intervalSeconds,
      activeFromMinute: data.activeFromMinute.present
          ? data.activeFromMinute.value
          : this.activeFromMinute,
      activeToMinute: data.activeToMinute.present
          ? data.activeToMinute.value
          : this.activeToMinute,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderDefinitionRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('activeFromMinute: $activeFromMinute, ')
          ..write('activeToMinute: $activeToMinute, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    label,
    intervalSeconds,
    activeFromMinute,
    activeToMinute,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderDefinitionRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.intervalSeconds == this.intervalSeconds &&
          other.activeFromMinute == this.activeFromMinute &&
          other.activeToMinute == this.activeToMinute &&
          other.enabled == this.enabled);
}

class ReminderDefinitionsCompanion
    extends UpdateCompanion<ReminderDefinitionRow> {
  final Value<String> id;
  final Value<ReminderKind> kind;
  final Value<String> label;
  final Value<int> intervalSeconds;
  final Value<int?> activeFromMinute;
  final Value<int?> activeToMinute;
  final Value<bool> enabled;
  final Value<int> rowid;
  const ReminderDefinitionsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.intervalSeconds = const Value.absent(),
    this.activeFromMinute = const Value.absent(),
    this.activeToMinute = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderDefinitionsCompanion.insert({
    required String id,
    required ReminderKind kind,
    required String label,
    required int intervalSeconds,
    this.activeFromMinute = const Value.absent(),
    this.activeToMinute = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       label = Value(label),
       intervalSeconds = Value(intervalSeconds);
  static Insertable<ReminderDefinitionRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<int>? intervalSeconds,
    Expression<int>? activeFromMinute,
    Expression<int>? activeToMinute,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (intervalSeconds != null) 'interval_seconds': intervalSeconds,
      if (activeFromMinute != null) 'active_from_minute': activeFromMinute,
      if (activeToMinute != null) 'active_to_minute': activeToMinute,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<ReminderKind>? kind,
    Value<String>? label,
    Value<int>? intervalSeconds,
    Value<int?>? activeFromMinute,
    Value<int?>? activeToMinute,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return ReminderDefinitionsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      activeFromMinute: activeFromMinute ?? this.activeFromMinute,
      activeToMinute: activeToMinute ?? this.activeToMinute,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ReminderDefinitionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (intervalSeconds.present) {
      map['interval_seconds'] = Variable<int>(intervalSeconds.value);
    }
    if (activeFromMinute.present) {
      map['active_from_minute'] = Variable<int>(activeFromMinute.value);
    }
    if (activeToMinute.present) {
      map['active_to_minute'] = Variable<int>(activeToMinute.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('activeFromMinute: $activeFromMinute, ')
          ..write('activeToMinute: $activeToMinute, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderOccurrencesTable extends ReminderOccurrences
    with TableInfo<$ReminderOccurrencesTable, ReminderOccurrenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminder_definitions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderOutcome, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderOutcome>(
        $ReminderOccurrencesTable.$converteroutcome,
      );
  static const VerificationMeta _respondedAtMeta = const VerificationMeta(
    'respondedAt',
  );
  @override
  late final GeneratedColumn<DateTime> respondedAt = GeneratedColumn<DateTime>(
    'responded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    definitionId,
    dueAt,
    outcome,
    respondedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderOccurrenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('responded_at')) {
      context.handle(
        _respondedAtMeta,
        respondedAt.isAcceptableOrUnknown(
          data['responded_at']!,
          _respondedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderOccurrenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderOccurrenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      outcome: $ReminderOccurrencesTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      respondedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}responded_at'],
      ),
    );
  }

  @override
  $ReminderOccurrencesTable createAlias(String alias) {
    return $ReminderOccurrencesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderOutcome, String, String> $converteroutcome =
      const EnumNameConverter<ReminderOutcome>(ReminderOutcome.values);
}

class ReminderOccurrenceRow extends DataClass
    implements Insertable<ReminderOccurrenceRow> {
  /// Identifies this firing.
  final String id;

  /// The reminder this came from.
  ///
  /// Deleting a definition takes its history with it, because a completion
  /// rate for a reminder the user no longer has is not a number worth showing.
  final String definitionId;

  /// When Kairo decided it was time.
  final DateTime dueAt;

  /// What became of it, stored by name.
  final ReminderOutcome outcome;

  /// When the user answered, or null while still pending.
  final DateTime? respondedAt;
  const ReminderOccurrenceRow({
    required this.id,
    required this.definitionId,
    required this.dueAt,
    required this.outcome,
    this.respondedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['definition_id'] = Variable<String>(definitionId);
    map['due_at'] = Variable<DateTime>(dueAt);
    {
      map['outcome'] = Variable<String>(
        $ReminderOccurrencesTable.$converteroutcome.toSql(outcome),
      );
    }
    if (!nullToAbsent || respondedAt != null) {
      map['responded_at'] = Variable<DateTime>(respondedAt);
    }
    return map;
  }

  ReminderOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return ReminderOccurrencesCompanion(
      id: Value(id),
      definitionId: Value(definitionId),
      dueAt: Value(dueAt),
      outcome: Value(outcome),
      respondedAt: respondedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(respondedAt),
    );
  }

  factory ReminderOccurrenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderOccurrenceRow(
      id: serializer.fromJson<String>(json['id']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      outcome: $ReminderOccurrencesTable.$converteroutcome.fromJson(
        serializer.fromJson<String>(json['outcome']),
      ),
      respondedAt: serializer.fromJson<DateTime?>(json['respondedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'definitionId': serializer.toJson<String>(definitionId),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'outcome': serializer.toJson<String>(
        $ReminderOccurrencesTable.$converteroutcome.toJson(outcome),
      ),
      'respondedAt': serializer.toJson<DateTime?>(respondedAt),
    };
  }

  ReminderOccurrenceRow copyWith({
    String? id,
    String? definitionId,
    DateTime? dueAt,
    ReminderOutcome? outcome,
    Value<DateTime?> respondedAt = const Value.absent(),
  }) => ReminderOccurrenceRow(
    id: id ?? this.id,
    definitionId: definitionId ?? this.definitionId,
    dueAt: dueAt ?? this.dueAt,
    outcome: outcome ?? this.outcome,
    respondedAt: respondedAt.present ? respondedAt.value : this.respondedAt,
  );
  ReminderOccurrenceRow copyWithCompanion(ReminderOccurrencesCompanion data) {
    return ReminderOccurrenceRow(
      id: data.id.present ? data.id.value : this.id,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      respondedAt: data.respondedAt.present
          ? data.respondedAt.value
          : this.respondedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderOccurrenceRow(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('dueAt: $dueAt, ')
          ..write('outcome: $outcome, ')
          ..write('respondedAt: $respondedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, definitionId, dueAt, outcome, respondedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderOccurrenceRow &&
          other.id == this.id &&
          other.definitionId == this.definitionId &&
          other.dueAt == this.dueAt &&
          other.outcome == this.outcome &&
          other.respondedAt == this.respondedAt);
}

class ReminderOccurrencesCompanion
    extends UpdateCompanion<ReminderOccurrenceRow> {
  final Value<String> id;
  final Value<String> definitionId;
  final Value<DateTime> dueAt;
  final Value<ReminderOutcome> outcome;
  final Value<DateTime?> respondedAt;
  final Value<int> rowid;
  const ReminderOccurrencesCompanion({
    this.id = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.respondedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderOccurrencesCompanion.insert({
    required String id,
    required String definitionId,
    required DateTime dueAt,
    required ReminderOutcome outcome,
    this.respondedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       definitionId = Value(definitionId),
       dueAt = Value(dueAt),
       outcome = Value(outcome);
  static Insertable<ReminderOccurrenceRow> custom({
    Expression<String>? id,
    Expression<String>? definitionId,
    Expression<DateTime>? dueAt,
    Expression<String>? outcome,
    Expression<DateTime>? respondedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (definitionId != null) 'definition_id': definitionId,
      if (dueAt != null) 'due_at': dueAt,
      if (outcome != null) 'outcome': outcome,
      if (respondedAt != null) 'responded_at': respondedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? definitionId,
    Value<DateTime>? dueAt,
    Value<ReminderOutcome>? outcome,
    Value<DateTime?>? respondedAt,
    Value<int>? rowid,
  }) {
    return ReminderOccurrencesCompanion(
      id: id ?? this.id,
      definitionId: definitionId ?? this.definitionId,
      dueAt: dueAt ?? this.dueAt,
      outcome: outcome ?? this.outcome,
      respondedAt: respondedAt ?? this.respondedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $ReminderOccurrencesTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (respondedAt.present) {
      map['responded_at'] = Variable<DateTime>(respondedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('dueAt: $dueAt, ')
          ..write('outcome: $outcome, ')
          ..write('respondedAt: $respondedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTableTable extends UserSettingsTable
    with TableInfo<$UserSettingsTableTable, UserSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quietFromMinuteMeta = const VerificationMeta(
    'quietFromMinute',
  );
  @override
  late final GeneratedColumn<int> quietFromMinute = GeneratedColumn<int>(
    'quiet_from_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quietToMinuteMeta = const VerificationMeta(
    'quietToMinute',
  );
  @override
  late final GeneratedColumn<int> quietToMinute = GeneratedColumn<int>(
    'quiet_to_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _launchAtLoginMeta = const VerificationMeta(
    'launchAtLogin',
  );
  @override
  late final GeneratedColumn<bool> launchAtLogin = GeneratedColumn<bool>(
    'launch_at_login',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("launch_at_login" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _characterEnabledMeta = const VerificationMeta(
    'characterEnabled',
  );
  @override
  late final GeneratedColumn<bool> characterEnabled = GeneratedColumn<bool>(
    'character_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("character_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _soundEnabledMeta = const VerificationMeta(
    'soundEnabled',
  );
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
    'sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quietFromMinute,
    quietToMinute,
    launchAtLogin,
    characterEnabled,
    soundEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quiet_from_minute')) {
      context.handle(
        _quietFromMinuteMeta,
        quietFromMinute.isAcceptableOrUnknown(
          data['quiet_from_minute']!,
          _quietFromMinuteMeta,
        ),
      );
    }
    if (data.containsKey('quiet_to_minute')) {
      context.handle(
        _quietToMinuteMeta,
        quietToMinute.isAcceptableOrUnknown(
          data['quiet_to_minute']!,
          _quietToMinuteMeta,
        ),
      );
    }
    if (data.containsKey('launch_at_login')) {
      context.handle(
        _launchAtLoginMeta,
        launchAtLogin.isAcceptableOrUnknown(
          data['launch_at_login']!,
          _launchAtLoginMeta,
        ),
      );
    }
    if (data.containsKey('character_enabled')) {
      context.handle(
        _characterEnabledMeta,
        characterEnabled.isAcceptableOrUnknown(
          data['character_enabled']!,
          _characterEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
        _soundEnabledMeta,
        soundEnabled.isAcceptableOrUnknown(
          data['sound_enabled']!,
          _soundEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      quietFromMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_from_minute'],
      ),
      quietToMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_to_minute'],
      ),
      launchAtLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}launch_at_login'],
      )!,
      characterEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}character_enabled'],
      )!,
      soundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_enabled'],
      )!,
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }
}

class UserSettingsRow extends DataClass implements Insertable<UserSettingsRow> {
  /// Always [settingsRowId]. Present so the row can be upserted by key.
  final int id;

  /// The first minute of the day Kairo stays silent, or null for none.
  final int? quietFromMinute;

  /// The minute of the day it stops being silent, or null for none.
  final int? quietToMinute;

  /// Whether Kairo starts when the user logs in.
  final bool launchAtLogin;

  /// Whether the character is shown on the desktop.
  final bool characterEnabled;

  /// Whether reminders make a sound.
  final bool soundEnabled;
  const UserSettingsRow({
    required this.id,
    this.quietFromMinute,
    this.quietToMinute,
    required this.launchAtLogin,
    required this.characterEnabled,
    required this.soundEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || quietFromMinute != null) {
      map['quiet_from_minute'] = Variable<int>(quietFromMinute);
    }
    if (!nullToAbsent || quietToMinute != null) {
      map['quiet_to_minute'] = Variable<int>(quietToMinute);
    }
    map['launch_at_login'] = Variable<bool>(launchAtLogin);
    map['character_enabled'] = Variable<bool>(characterEnabled);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    return map;
  }

  UserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsTableCompanion(
      id: Value(id),
      quietFromMinute: quietFromMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(quietFromMinute),
      quietToMinute: quietToMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(quietToMinute),
      launchAtLogin: Value(launchAtLogin),
      characterEnabled: Value(characterEnabled),
      soundEnabled: Value(soundEnabled),
    );
  }

  factory UserSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      quietFromMinute: serializer.fromJson<int?>(json['quietFromMinute']),
      quietToMinute: serializer.fromJson<int?>(json['quietToMinute']),
      launchAtLogin: serializer.fromJson<bool>(json['launchAtLogin']),
      characterEnabled: serializer.fromJson<bool>(json['characterEnabled']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'quietFromMinute': serializer.toJson<int?>(quietFromMinute),
      'quietToMinute': serializer.toJson<int?>(quietToMinute),
      'launchAtLogin': serializer.toJson<bool>(launchAtLogin),
      'characterEnabled': serializer.toJson<bool>(characterEnabled),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
    };
  }

  UserSettingsRow copyWith({
    int? id,
    Value<int?> quietFromMinute = const Value.absent(),
    Value<int?> quietToMinute = const Value.absent(),
    bool? launchAtLogin,
    bool? characterEnabled,
    bool? soundEnabled,
  }) => UserSettingsRow(
    id: id ?? this.id,
    quietFromMinute: quietFromMinute.present
        ? quietFromMinute.value
        : this.quietFromMinute,
    quietToMinute: quietToMinute.present
        ? quietToMinute.value
        : this.quietToMinute,
    launchAtLogin: launchAtLogin ?? this.launchAtLogin,
    characterEnabled: characterEnabled ?? this.characterEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
  );
  UserSettingsRow copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      quietFromMinute: data.quietFromMinute.present
          ? data.quietFromMinute.value
          : this.quietFromMinute,
      quietToMinute: data.quietToMinute.present
          ? data.quietToMinute.value
          : this.quietToMinute,
      launchAtLogin: data.launchAtLogin.present
          ? data.launchAtLogin.value
          : this.launchAtLogin,
      characterEnabled: data.characterEnabled.present
          ? data.characterEnabled.value
          : this.characterEnabled,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRow(')
          ..write('id: $id, ')
          ..write('quietFromMinute: $quietFromMinute, ')
          ..write('quietToMinute: $quietToMinute, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('characterEnabled: $characterEnabled, ')
          ..write('soundEnabled: $soundEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quietFromMinute,
    quietToMinute,
    launchAtLogin,
    characterEnabled,
    soundEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsRow &&
          other.id == this.id &&
          other.quietFromMinute == this.quietFromMinute &&
          other.quietToMinute == this.quietToMinute &&
          other.launchAtLogin == this.launchAtLogin &&
          other.characterEnabled == this.characterEnabled &&
          other.soundEnabled == this.soundEnabled);
}

class UserSettingsTableCompanion extends UpdateCompanion<UserSettingsRow> {
  final Value<int> id;
  final Value<int?> quietFromMinute;
  final Value<int?> quietToMinute;
  final Value<bool> launchAtLogin;
  final Value<bool> characterEnabled;
  final Value<bool> soundEnabled;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.quietFromMinute = const Value.absent(),
    this.quietToMinute = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.characterEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.quietFromMinute = const Value.absent(),
    this.quietToMinute = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.characterEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
  });
  static Insertable<UserSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? quietFromMinute,
    Expression<int>? quietToMinute,
    Expression<bool>? launchAtLogin,
    Expression<bool>? characterEnabled,
    Expression<bool>? soundEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quietFromMinute != null) 'quiet_from_minute': quietFromMinute,
      if (quietToMinute != null) 'quiet_to_minute': quietToMinute,
      if (launchAtLogin != null) 'launch_at_login': launchAtLogin,
      if (characterEnabled != null) 'character_enabled': characterEnabled,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
    });
  }

  UserSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<int?>? quietFromMinute,
    Value<int?>? quietToMinute,
    Value<bool>? launchAtLogin,
    Value<bool>? characterEnabled,
    Value<bool>? soundEnabled,
  }) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      quietFromMinute: quietFromMinute ?? this.quietFromMinute,
      quietToMinute: quietToMinute ?? this.quietToMinute,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      characterEnabled: characterEnabled ?? this.characterEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (quietFromMinute.present) {
      map['quiet_from_minute'] = Variable<int>(quietFromMinute.value);
    }
    if (quietToMinute.present) {
      map['quiet_to_minute'] = Variable<int>(quietToMinute.value);
    }
    if (launchAtLogin.present) {
      map['launch_at_login'] = Variable<bool>(launchAtLogin.value);
    }
    if (characterEnabled.present) {
      map['character_enabled'] = Variable<bool>(characterEnabled.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('quietFromMinute: $quietFromMinute, ')
          ..write('quietToMinute: $quietToMinute, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('characterEnabled: $characterEnabled, ')
          ..write('soundEnabled: $soundEnabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$KairoDatabase extends GeneratedDatabase {
  _$KairoDatabase(QueryExecutor e) : super(e);
  $KairoDatabaseManager get managers => $KairoDatabaseManager(this);
  late final $ReminderDefinitionsTable reminderDefinitions =
      $ReminderDefinitionsTable(this);
  late final $ReminderOccurrencesTable reminderOccurrences =
      $ReminderOccurrencesTable(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reminderDefinitions,
    reminderOccurrences,
    userSettingsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reminder_definitions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminder_occurrences', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ReminderDefinitionsTableCreateCompanionBuilder =
    ReminderDefinitionsCompanion Function({
      required String id,
      required ReminderKind kind,
      required String label,
      required int intervalSeconds,
      Value<int?> activeFromMinute,
      Value<int?> activeToMinute,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$ReminderDefinitionsTableUpdateCompanionBuilder =
    ReminderDefinitionsCompanion Function({
      Value<String> id,
      Value<ReminderKind> kind,
      Value<String> label,
      Value<int> intervalSeconds,
      Value<int?> activeFromMinute,
      Value<int?> activeToMinute,
      Value<bool> enabled,
      Value<int> rowid,
    });

final class $$ReminderDefinitionsTableReferences
    extends
        BaseReferences<
          _$KairoDatabase,
          $ReminderDefinitionsTable,
          ReminderDefinitionRow
        > {
  $$ReminderDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ReminderOccurrencesTable,
    List<ReminderOccurrenceRow>
  >
  _reminderOccurrencesRefsTable(_$KairoDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reminderOccurrences,
        aliasName:
            'reminder_definitions__id__reminder_occurrences__definition_id',
      );

  $$ReminderOccurrencesTableProcessedTableManager get reminderOccurrencesRefs {
    final manager = $$ReminderOccurrencesTableTableManager(
      $_db,
      $_db.reminderOccurrences,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reminderOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReminderDefinitionsTableFilterComposer
    extends Composer<_$KairoDatabase, $ReminderDefinitionsTable> {
  $$ReminderDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderKind, ReminderKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalSeconds => $composableBuilder(
    column: $table.intervalSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeFromMinute => $composableBuilder(
    column: $table.activeFromMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeToMinute => $composableBuilder(
    column: $table.activeToMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reminderOccurrencesRefs(
    Expression<bool> Function($$ReminderOccurrencesTableFilterComposer f) f,
  ) {
    final $$ReminderOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderOccurrences,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.reminderOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReminderDefinitionsTableOrderingComposer
    extends Composer<_$KairoDatabase, $ReminderDefinitionsTable> {
  $$ReminderDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalSeconds => $composableBuilder(
    column: $table.intervalSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeFromMinute => $composableBuilder(
    column: $table.activeFromMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeToMinute => $composableBuilder(
    column: $table.activeToMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderDefinitionsTableAnnotationComposer
    extends Composer<_$KairoDatabase, $ReminderDefinitionsTable> {
  $$ReminderDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get intervalSeconds => $composableBuilder(
    column: $table.intervalSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeFromMinute => $composableBuilder(
    column: $table.activeFromMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeToMinute => $composableBuilder(
    column: $table.activeToMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  Expression<T> reminderOccurrencesRefs<T extends Object>(
    Expression<T> Function($$ReminderOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$ReminderOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reminderOccurrences,
          getReferencedColumn: (t) => t.definitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.reminderOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReminderDefinitionsTableTableManager
    extends
        RootTableManager<
          _$KairoDatabase,
          $ReminderDefinitionsTable,
          ReminderDefinitionRow,
          $$ReminderDefinitionsTableFilterComposer,
          $$ReminderDefinitionsTableOrderingComposer,
          $$ReminderDefinitionsTableAnnotationComposer,
          $$ReminderDefinitionsTableCreateCompanionBuilder,
          $$ReminderDefinitionsTableUpdateCompanionBuilder,
          (ReminderDefinitionRow, $$ReminderDefinitionsTableReferences),
          ReminderDefinitionRow,
          PrefetchHooks Function({bool reminderOccurrencesRefs})
        > {
  $$ReminderDefinitionsTableTableManager(
    _$KairoDatabase db,
    $ReminderDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<ReminderKind> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> intervalSeconds = const Value.absent(),
                Value<int?> activeFromMinute = const Value.absent(),
                Value<int?> activeToMinute = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderDefinitionsCompanion(
                id: id,
                kind: kind,
                label: label,
                intervalSeconds: intervalSeconds,
                activeFromMinute: activeFromMinute,
                activeToMinute: activeToMinute,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required ReminderKind kind,
                required String label,
                required int intervalSeconds,
                Value<int?> activeFromMinute = const Value.absent(),
                Value<int?> activeToMinute = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderDefinitionsCompanion.insert(
                id: id,
                kind: kind,
                label: label,
                intervalSeconds: intervalSeconds,
                activeFromMinute: activeFromMinute,
                activeToMinute: activeToMinute,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderOccurrencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reminderOccurrencesRefs) db.reminderOccurrences,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reminderOccurrencesRefs)
                    await $_getPrefetchedData<
                      ReminderDefinitionRow,
                      $ReminderDefinitionsTable,
                      ReminderOccurrenceRow
                    >(
                      currentTable: table,
                      referencedTable: $$ReminderDefinitionsTableReferences
                          ._reminderOccurrencesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReminderDefinitionsTableReferences(
                            db,
                            table,
                            p0,
                          ).reminderOccurrencesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.definitionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReminderDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$KairoDatabase,
      $ReminderDefinitionsTable,
      ReminderDefinitionRow,
      $$ReminderDefinitionsTableFilterComposer,
      $$ReminderDefinitionsTableOrderingComposer,
      $$ReminderDefinitionsTableAnnotationComposer,
      $$ReminderDefinitionsTableCreateCompanionBuilder,
      $$ReminderDefinitionsTableUpdateCompanionBuilder,
      (ReminderDefinitionRow, $$ReminderDefinitionsTableReferences),
      ReminderDefinitionRow,
      PrefetchHooks Function({bool reminderOccurrencesRefs})
    >;
typedef $$ReminderOccurrencesTableCreateCompanionBuilder =
    ReminderOccurrencesCompanion Function({
      required String id,
      required String definitionId,
      required DateTime dueAt,
      required ReminderOutcome outcome,
      Value<DateTime?> respondedAt,
      Value<int> rowid,
    });
typedef $$ReminderOccurrencesTableUpdateCompanionBuilder =
    ReminderOccurrencesCompanion Function({
      Value<String> id,
      Value<String> definitionId,
      Value<DateTime> dueAt,
      Value<ReminderOutcome> outcome,
      Value<DateTime?> respondedAt,
      Value<int> rowid,
    });

final class $$ReminderOccurrencesTableReferences
    extends
        BaseReferences<
          _$KairoDatabase,
          $ReminderOccurrencesTable,
          ReminderOccurrenceRow
        > {
  $$ReminderOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReminderDefinitionsTable _definitionIdTable(_$KairoDatabase db) =>
      db.reminderDefinitions.createAlias(
        'reminder_occurrences__definition_id__reminder_definitions__id',
      );

  $$ReminderDefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<String>('definition_id')!;

    final manager = $$ReminderDefinitionsTableTableManager(
      $_db,
      $_db.reminderDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderOccurrencesTableFilterComposer
    extends Composer<_$KairoDatabase, $ReminderOccurrencesTable> {
  $$ReminderOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderOutcome, ReminderOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get respondedAt => $composableBuilder(
    column: $table.respondedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ReminderDefinitionsTableFilterComposer get definitionId {
    final $$ReminderDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.reminderDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.reminderDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderOccurrencesTableOrderingComposer
    extends Composer<_$KairoDatabase, $ReminderOccurrencesTable> {
  $$ReminderOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get respondedAt => $composableBuilder(
    column: $table.respondedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReminderDefinitionsTableOrderingComposer get definitionId {
    final $$ReminderDefinitionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.definitionId,
          referencedTable: $db.reminderDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderDefinitionsTableOrderingComposer(
                $db: $db,
                $table: $db.reminderDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReminderOccurrencesTableAnnotationComposer
    extends Composer<_$KairoDatabase, $ReminderOccurrencesTable> {
  $$ReminderOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderOutcome, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get respondedAt => $composableBuilder(
    column: $table.respondedAt,
    builder: (column) => column,
  );

  $$ReminderDefinitionsTableAnnotationComposer get definitionId {
    final $$ReminderDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.definitionId,
          referencedTable: $db.reminderDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReminderDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.reminderDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ReminderOccurrencesTableTableManager
    extends
        RootTableManager<
          _$KairoDatabase,
          $ReminderOccurrencesTable,
          ReminderOccurrenceRow,
          $$ReminderOccurrencesTableFilterComposer,
          $$ReminderOccurrencesTableOrderingComposer,
          $$ReminderOccurrencesTableAnnotationComposer,
          $$ReminderOccurrencesTableCreateCompanionBuilder,
          $$ReminderOccurrencesTableUpdateCompanionBuilder,
          (ReminderOccurrenceRow, $$ReminderOccurrencesTableReferences),
          ReminderOccurrenceRow,
          PrefetchHooks Function({bool definitionId})
        > {
  $$ReminderOccurrencesTableTableManager(
    _$KairoDatabase db,
    $ReminderOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderOccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<ReminderOutcome> outcome = const Value.absent(),
                Value<DateTime?> respondedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderOccurrencesCompanion(
                id: id,
                definitionId: definitionId,
                dueAt: dueAt,
                outcome: outcome,
                respondedAt: respondedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String definitionId,
                required DateTime dueAt,
                required ReminderOutcome outcome,
                Value<DateTime?> respondedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderOccurrencesCompanion.insert(
                id: id,
                definitionId: definitionId,
                dueAt: dueAt,
                outcome: outcome,
                respondedAt: respondedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({definitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (definitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.definitionId,
                                referencedTable:
                                    $$ReminderOccurrencesTableReferences
                                        ._definitionIdTable(db),
                                referencedColumn:
                                    $$ReminderOccurrencesTableReferences
                                        ._definitionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$KairoDatabase,
      $ReminderOccurrencesTable,
      ReminderOccurrenceRow,
      $$ReminderOccurrencesTableFilterComposer,
      $$ReminderOccurrencesTableOrderingComposer,
      $$ReminderOccurrencesTableAnnotationComposer,
      $$ReminderOccurrencesTableCreateCompanionBuilder,
      $$ReminderOccurrencesTableUpdateCompanionBuilder,
      (ReminderOccurrenceRow, $$ReminderOccurrencesTableReferences),
      ReminderOccurrenceRow,
      PrefetchHooks Function({bool definitionId})
    >;
typedef $$UserSettingsTableTableCreateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<int> id,
      Value<int?> quietFromMinute,
      Value<int?> quietToMinute,
      Value<bool> launchAtLogin,
      Value<bool> characterEnabled,
      Value<bool> soundEnabled,
    });
typedef $$UserSettingsTableTableUpdateCompanionBuilder =
    UserSettingsTableCompanion Function({
      Value<int> id,
      Value<int?> quietFromMinute,
      Value<int?> quietToMinute,
      Value<bool> launchAtLogin,
      Value<bool> characterEnabled,
      Value<bool> soundEnabled,
    });

class $$UserSettingsTableTableFilterComposer
    extends Composer<_$KairoDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietFromMinute => $composableBuilder(
    column: $table.quietFromMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietToMinute => $composableBuilder(
    column: $table.quietToMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get characterEnabled => $composableBuilder(
    column: $table.characterEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableTableOrderingComposer
    extends Composer<_$KairoDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietFromMinute => $composableBuilder(
    column: $table.quietFromMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietToMinute => $composableBuilder(
    column: $table.quietToMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get characterEnabled => $composableBuilder(
    column: $table.characterEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableTableAnnotationComposer
    extends Composer<_$KairoDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quietFromMinute => $composableBuilder(
    column: $table.quietFromMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietToMinute => $composableBuilder(
    column: $table.quietToMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get characterEnabled => $composableBuilder(
    column: $table.characterEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
    column: $table.soundEnabled,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableTableManager
    extends
        RootTableManager<
          _$KairoDatabase,
          $UserSettingsTableTable,
          UserSettingsRow,
          $$UserSettingsTableTableFilterComposer,
          $$UserSettingsTableTableOrderingComposer,
          $$UserSettingsTableTableAnnotationComposer,
          $$UserSettingsTableTableCreateCompanionBuilder,
          $$UserSettingsTableTableUpdateCompanionBuilder,
          (
            UserSettingsRow,
            BaseReferences<
              _$KairoDatabase,
              $UserSettingsTableTable,
              UserSettingsRow
            >,
          ),
          UserSettingsRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableTableManager(
    _$KairoDatabase db,
    $UserSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> quietFromMinute = const Value.absent(),
                Value<int?> quietToMinute = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<bool> characterEnabled = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
              }) => UserSettingsTableCompanion(
                id: id,
                quietFromMinute: quietFromMinute,
                quietToMinute: quietToMinute,
                launchAtLogin: launchAtLogin,
                characterEnabled: characterEnabled,
                soundEnabled: soundEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> quietFromMinute = const Value.absent(),
                Value<int?> quietToMinute = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<bool> characterEnabled = const Value.absent(),
                Value<bool> soundEnabled = const Value.absent(),
              }) => UserSettingsTableCompanion.insert(
                id: id,
                quietFromMinute: quietFromMinute,
                quietToMinute: quietToMinute,
                launchAtLogin: launchAtLogin,
                characterEnabled: characterEnabled,
                soundEnabled: soundEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$KairoDatabase,
      $UserSettingsTableTable,
      UserSettingsRow,
      $$UserSettingsTableTableFilterComposer,
      $$UserSettingsTableTableOrderingComposer,
      $$UserSettingsTableTableAnnotationComposer,
      $$UserSettingsTableTableCreateCompanionBuilder,
      $$UserSettingsTableTableUpdateCompanionBuilder,
      (
        UserSettingsRow,
        BaseReferences<
          _$KairoDatabase,
          $UserSettingsTableTable,
          UserSettingsRow
        >,
      ),
      UserSettingsRow,
      PrefetchHooks Function()
    >;

class $KairoDatabaseManager {
  final _$KairoDatabase _db;
  $KairoDatabaseManager(this._db);
  $$ReminderDefinitionsTableTableManager get reminderDefinitions =>
      $$ReminderDefinitionsTableTableManager(_db, _db.reminderDefinitions);
  $$ReminderOccurrencesTableTableManager get reminderOccurrences =>
      $$ReminderOccurrencesTableTableManager(_db, _db.reminderOccurrences);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
}
