// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// ignore_for_file: type=lint
class $PrestatairesTable extends Prestataires
    with TableInfo<$PrestatairesTable, PrestataireLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrestatairesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categorieMeta =
      const VerificationMeta('categorie');
  @override
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
      'categorie', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quartierMeta =
      const VerificationMeta('quartier');
  @override
  late final GeneratedColumn<String> quartier = GeneratedColumn<String>(
      'quartier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _prixBaseMeta =
      const VerificationMeta('prixBase');
  @override
  late final GeneratedColumn<int> prixBase = GeneratedColumn<int>(
      'prix_base', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _photosMeta = const VerificationMeta('photos');
  @override
  late final GeneratedColumn<String> photos = GeneratedColumn<String>(
      'photos', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _tarifsMeta = const VerificationMeta('tarifs');
  @override
  late final GeneratedColumn<String> tarifs = GeneratedColumn<String>(
      'tarifs', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _telephoneMeta =
      const VerificationMeta('telephone');
  @override
  late final GeneratedColumn<String> telephone = GeneratedColumn<String>(
      'telephone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _vuesMeta = const VerificationMeta('vues');
  @override
  late final GeneratedColumn<int> vues = GeneratedColumn<int>(
      'vues', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        uid,
        nom,
        categorie,
        quartier,
        description,
        prixBase,
        photos,
        tarifs,
        telephone,
        statut,
        vues,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prestataires';
  @override
  VerificationContext validateIntegrity(Insertable<PrestataireLocal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('categorie')) {
      context.handle(_categorieMeta,
          categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta));
    } else if (isInserting) {
      context.missing(_categorieMeta);
    }
    if (data.containsKey('quartier')) {
      context.handle(_quartierMeta,
          quartier.isAcceptableOrUnknown(data['quartier']!, _quartierMeta));
    } else if (isInserting) {
      context.missing(_quartierMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('prix_base')) {
      context.handle(_prixBaseMeta,
          prixBase.isAcceptableOrUnknown(data['prix_base']!, _prixBaseMeta));
    }
    if (data.containsKey('photos')) {
      context.handle(_photosMeta,
          photos.isAcceptableOrUnknown(data['photos']!, _photosMeta));
    }
    if (data.containsKey('tarifs')) {
      context.handle(_tarifsMeta,
          tarifs.isAcceptableOrUnknown(data['tarifs']!, _tarifsMeta));
    }
    if (data.containsKey('telephone')) {
      context.handle(_telephoneMeta,
          telephone.isAcceptableOrUnknown(data['telephone']!, _telephoneMeta));
    } else if (isInserting) {
      context.missing(_telephoneMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('vues')) {
      context.handle(
          _vuesMeta, vues.isAcceptableOrUnknown(data['vues']!, _vuesMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  PrestataireLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrestataireLocal(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      categorie: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categorie'])!,
      quartier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quartier'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      prixBase: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prix_base'])!,
      photos: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photos'])!,
      tarifs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tarifs'])!,
      telephone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telephone'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      vues: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vues'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PrestatairesTable createAlias(String alias) {
    return $PrestatairesTable(attachedDatabase, alias);
  }
}

class PrestataireLocal extends DataClass
    implements Insertable<PrestataireLocal> {
  final String uid;
  final String nom;
  final String categorie;
  final String quartier;
  final String description;
  final int prixBase;
  final String photos;
  final String tarifs;
  final String telephone;
  final String statut;
  final int vues;
  final DateTime updatedAt;
  const PrestataireLocal(
      {required this.uid,
      required this.nom,
      required this.categorie,
      required this.quartier,
      required this.description,
      required this.prixBase,
      required this.photos,
      required this.tarifs,
      required this.telephone,
      required this.statut,
      required this.vues,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['nom'] = Variable<String>(nom);
    map['categorie'] = Variable<String>(categorie);
    map['quartier'] = Variable<String>(quartier);
    map['description'] = Variable<String>(description);
    map['prix_base'] = Variable<int>(prixBase);
    map['photos'] = Variable<String>(photos);
    map['tarifs'] = Variable<String>(tarifs);
    map['telephone'] = Variable<String>(telephone);
    map['statut'] = Variable<String>(statut);
    map['vues'] = Variable<int>(vues);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrestatairesCompanion toCompanion(bool nullToAbsent) {
    return PrestatairesCompanion(
      uid: Value(uid),
      nom: Value(nom),
      categorie: Value(categorie),
      quartier: Value(quartier),
      description: Value(description),
      prixBase: Value(prixBase),
      photos: Value(photos),
      tarifs: Value(tarifs),
      telephone: Value(telephone),
      statut: Value(statut),
      vues: Value(vues),
      updatedAt: Value(updatedAt),
    );
  }

  factory PrestataireLocal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrestataireLocal(
      uid: serializer.fromJson<String>(json['uid']),
      nom: serializer.fromJson<String>(json['nom']),
      categorie: serializer.fromJson<String>(json['categorie']),
      quartier: serializer.fromJson<String>(json['quartier']),
      description: serializer.fromJson<String>(json['description']),
      prixBase: serializer.fromJson<int>(json['prixBase']),
      photos: serializer.fromJson<String>(json['photos']),
      tarifs: serializer.fromJson<String>(json['tarifs']),
      telephone: serializer.fromJson<String>(json['telephone']),
      statut: serializer.fromJson<String>(json['statut']),
      vues: serializer.fromJson<int>(json['vues']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'nom': serializer.toJson<String>(nom),
      'categorie': serializer.toJson<String>(categorie),
      'quartier': serializer.toJson<String>(quartier),
      'description': serializer.toJson<String>(description),
      'prixBase': serializer.toJson<int>(prixBase),
      'photos': serializer.toJson<String>(photos),
      'tarifs': serializer.toJson<String>(tarifs),
      'telephone': serializer.toJson<String>(telephone),
      'statut': serializer.toJson<String>(statut),
      'vues': serializer.toJson<int>(vues),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PrestataireLocal copyWith(
          {String? uid,
          String? nom,
          String? categorie,
          String? quartier,
          String? description,
          int? prixBase,
          String? photos,
          String? tarifs,
          String? telephone,
          String? statut,
          int? vues,
          DateTime? updatedAt}) =>
      PrestataireLocal(
        uid: uid ?? this.uid,
        nom: nom ?? this.nom,
        categorie: categorie ?? this.categorie,
        quartier: quartier ?? this.quartier,
        description: description ?? this.description,
        prixBase: prixBase ?? this.prixBase,
        photos: photos ?? this.photos,
        tarifs: tarifs ?? this.tarifs,
        telephone: telephone ?? this.telephone,
        statut: statut ?? this.statut,
        vues: vues ?? this.vues,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PrestataireLocal copyWithCompanion(PrestatairesCompanion data) {
    return PrestataireLocal(
      uid: data.uid.present ? data.uid.value : this.uid,
      nom: data.nom.present ? data.nom.value : this.nom,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      quartier: data.quartier.present ? data.quartier.value : this.quartier,
      description:
          data.description.present ? data.description.value : this.description,
      prixBase: data.prixBase.present ? data.prixBase.value : this.prixBase,
      photos: data.photos.present ? data.photos.value : this.photos,
      tarifs: data.tarifs.present ? data.tarifs.value : this.tarifs,
      telephone: data.telephone.present ? data.telephone.value : this.telephone,
      statut: data.statut.present ? data.statut.value : this.statut,
      vues: data.vues.present ? data.vues.value : this.vues,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrestataireLocal(')
          ..write('uid: $uid, ')
          ..write('nom: $nom, ')
          ..write('categorie: $categorie, ')
          ..write('quartier: $quartier, ')
          ..write('description: $description, ')
          ..write('prixBase: $prixBase, ')
          ..write('photos: $photos, ')
          ..write('tarifs: $tarifs, ')
          ..write('telephone: $telephone, ')
          ..write('statut: $statut, ')
          ..write('vues: $vues, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, nom, categorie, quartier, description,
      prixBase, photos, tarifs, telephone, statut, vues, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrestataireLocal &&
          other.uid == this.uid &&
          other.nom == this.nom &&
          other.categorie == this.categorie &&
          other.quartier == this.quartier &&
          other.description == this.description &&
          other.prixBase == this.prixBase &&
          other.photos == this.photos &&
          other.tarifs == this.tarifs &&
          other.telephone == this.telephone &&
          other.statut == this.statut &&
          other.vues == this.vues &&
          other.updatedAt == this.updatedAt);
}

class PrestatairesCompanion extends UpdateCompanion<PrestataireLocal> {
  final Value<String> uid;
  final Value<String> nom;
  final Value<String> categorie;
  final Value<String> quartier;
  final Value<String> description;
  final Value<int> prixBase;
  final Value<String> photos;
  final Value<String> tarifs;
  final Value<String> telephone;
  final Value<String> statut;
  final Value<int> vues;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PrestatairesCompanion({
    this.uid = const Value.absent(),
    this.nom = const Value.absent(),
    this.categorie = const Value.absent(),
    this.quartier = const Value.absent(),
    this.description = const Value.absent(),
    this.prixBase = const Value.absent(),
    this.photos = const Value.absent(),
    this.tarifs = const Value.absent(),
    this.telephone = const Value.absent(),
    this.statut = const Value.absent(),
    this.vues = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrestatairesCompanion.insert({
    required String uid,
    required String nom,
    required String categorie,
    required String quartier,
    this.description = const Value.absent(),
    this.prixBase = const Value.absent(),
    this.photos = const Value.absent(),
    this.tarifs = const Value.absent(),
    required String telephone,
    this.statut = const Value.absent(),
    this.vues = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        nom = Value(nom),
        categorie = Value(categorie),
        quartier = Value(quartier),
        telephone = Value(telephone),
        updatedAt = Value(updatedAt);
  static Insertable<PrestataireLocal> custom({
    Expression<String>? uid,
    Expression<String>? nom,
    Expression<String>? categorie,
    Expression<String>? quartier,
    Expression<String>? description,
    Expression<int>? prixBase,
    Expression<String>? photos,
    Expression<String>? tarifs,
    Expression<String>? telephone,
    Expression<String>? statut,
    Expression<int>? vues,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (nom != null) 'nom': nom,
      if (categorie != null) 'categorie': categorie,
      if (quartier != null) 'quartier': quartier,
      if (description != null) 'description': description,
      if (prixBase != null) 'prix_base': prixBase,
      if (photos != null) 'photos': photos,
      if (tarifs != null) 'tarifs': tarifs,
      if (telephone != null) 'telephone': telephone,
      if (statut != null) 'statut': statut,
      if (vues != null) 'vues': vues,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrestatairesCompanion copyWith(
      {Value<String>? uid,
      Value<String>? nom,
      Value<String>? categorie,
      Value<String>? quartier,
      Value<String>? description,
      Value<int>? prixBase,
      Value<String>? photos,
      Value<String>? tarifs,
      Value<String>? telephone,
      Value<String>? statut,
      Value<int>? vues,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PrestatairesCompanion(
      uid: uid ?? this.uid,
      nom: nom ?? this.nom,
      categorie: categorie ?? this.categorie,
      quartier: quartier ?? this.quartier,
      description: description ?? this.description,
      prixBase: prixBase ?? this.prixBase,
      photos: photos ?? this.photos,
      tarifs: tarifs ?? this.tarifs,
      telephone: telephone ?? this.telephone,
      statut: statut ?? this.statut,
      vues: vues ?? this.vues,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (quartier.present) {
      map['quartier'] = Variable<String>(quartier.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (prixBase.present) {
      map['prix_base'] = Variable<int>(prixBase.value);
    }
    if (photos.present) {
      map['photos'] = Variable<String>(photos.value);
    }
    if (tarifs.present) {
      map['tarifs'] = Variable<String>(tarifs.value);
    }
    if (telephone.present) {
      map['telephone'] = Variable<String>(telephone.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (vues.present) {
      map['vues'] = Variable<int>(vues.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrestatairesCompanion(')
          ..write('uid: $uid, ')
          ..write('nom: $nom, ')
          ..write('categorie: $categorie, ')
          ..write('quartier: $quartier, ')
          ..write('description: $description, ')
          ..write('prixBase: $prixBase, ')
          ..write('photos: $photos, ')
          ..write('tarifs: $tarifs, ')
          ..write('telephone: $telephone, ')
          ..write('statut: $statut, ')
          ..write('vues: $vues, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommandesTable extends Commandes
    with TableInfo<$CommandesTable, CommandeLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommandesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientTelephoneMeta =
      const VerificationMeta('clientTelephone');
  @override
  late final GeneratedColumn<String> clientTelephone = GeneratedColumn<String>(
      'client_telephone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prestataireUidMeta =
      const VerificationMeta('prestataireUid');
  @override
  late final GeneratedColumn<String> prestataireUid = GeneratedColumn<String>(
      'prestataire_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageTexteMeta =
      const VerificationMeta('messageTexte');
  @override
  late final GeneratedColumn<String> messageTexte = GeneratedColumn<String>(
      'message_texte', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioLocalMeta =
      const VerificationMeta('audioLocal');
  @override
  late final GeneratedColumn<String> audioLocal = GeneratedColumn<String>(
      'audio_local', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioDureeMeta =
      const VerificationMeta('audioDuree');
  @override
  late final GeneratedColumn<int> audioDuree = GeneratedColumn<int>(
      'audio_duree', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _montantMeta =
      const VerificationMeta('montant');
  @override
  late final GeneratedColumn<int> montant = GeneratedColumn<int>(
      'montant', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('nouvelle'));
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
      'cree_le', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        uid,
        clientTelephone,
        prestataireUid,
        messageTexte,
        audioLocal,
        audioUrl,
        audioDuree,
        montant,
        statut,
        creeLe,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commandes';
  @override
  VerificationContext validateIntegrity(Insertable<CommandeLocale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('client_telephone')) {
      context.handle(
          _clientTelephoneMeta,
          clientTelephone.isAcceptableOrUnknown(
              data['client_telephone']!, _clientTelephoneMeta));
    } else if (isInserting) {
      context.missing(_clientTelephoneMeta);
    }
    if (data.containsKey('prestataire_uid')) {
      context.handle(
          _prestataireUidMeta,
          prestataireUid.isAcceptableOrUnknown(
              data['prestataire_uid']!, _prestataireUidMeta));
    } else if (isInserting) {
      context.missing(_prestataireUidMeta);
    }
    if (data.containsKey('message_texte')) {
      context.handle(
          _messageTexteMeta,
          messageTexte.isAcceptableOrUnknown(
              data['message_texte']!, _messageTexteMeta));
    }
    if (data.containsKey('audio_local')) {
      context.handle(
          _audioLocalMeta,
          audioLocal.isAcceptableOrUnknown(
              data['audio_local']!, _audioLocalMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    if (data.containsKey('audio_duree')) {
      context.handle(
          _audioDureeMeta,
          audioDuree.isAcceptableOrUnknown(
              data['audio_duree']!, _audioDureeMeta));
    }
    if (data.containsKey('montant')) {
      context.handle(_montantMeta,
          montant.isAcceptableOrUnknown(data['montant']!, _montantMeta));
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    }
    if (data.containsKey('cree_le')) {
      context.handle(_creeLeMeta,
          creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta));
    } else if (isInserting) {
      context.missing(_creeLeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  CommandeLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommandeLocale(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      clientTelephone: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_telephone'])!,
      prestataireUid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prestataire_uid'])!,
      messageTexte: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_texte']),
      audioLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_local']),
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
      audioDuree: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}audio_duree'])!,
      montant: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}montant'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
      creeLe: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cree_le'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CommandesTable createAlias(String alias) {
    return $CommandesTable(attachedDatabase, alias);
  }
}

class CommandeLocale extends DataClass implements Insertable<CommandeLocale> {
  final String uid;
  final String clientTelephone;
  final String prestataireUid;
  final String? messageTexte;
  final String? audioLocal;
  final String? audioUrl;
  final int audioDuree;
  final int montant;
  final String statut;
  final DateTime creeLe;
  final DateTime updatedAt;
  const CommandeLocale(
      {required this.uid,
      required this.clientTelephone,
      required this.prestataireUid,
      this.messageTexte,
      this.audioLocal,
      this.audioUrl,
      required this.audioDuree,
      required this.montant,
      required this.statut,
      required this.creeLe,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['client_telephone'] = Variable<String>(clientTelephone);
    map['prestataire_uid'] = Variable<String>(prestataireUid);
    if (!nullToAbsent || messageTexte != null) {
      map['message_texte'] = Variable<String>(messageTexte);
    }
    if (!nullToAbsent || audioLocal != null) {
      map['audio_local'] = Variable<String>(audioLocal);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    map['audio_duree'] = Variable<int>(audioDuree);
    map['montant'] = Variable<int>(montant);
    map['statut'] = Variable<String>(statut);
    map['cree_le'] = Variable<DateTime>(creeLe);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CommandesCompanion toCompanion(bool nullToAbsent) {
    return CommandesCompanion(
      uid: Value(uid),
      clientTelephone: Value(clientTelephone),
      prestataireUid: Value(prestataireUid),
      messageTexte: messageTexte == null && nullToAbsent
          ? const Value.absent()
          : Value(messageTexte),
      audioLocal: audioLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(audioLocal),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      audioDuree: Value(audioDuree),
      montant: Value(montant),
      statut: Value(statut),
      creeLe: Value(creeLe),
      updatedAt: Value(updatedAt),
    );
  }

  factory CommandeLocale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommandeLocale(
      uid: serializer.fromJson<String>(json['uid']),
      clientTelephone: serializer.fromJson<String>(json['clientTelephone']),
      prestataireUid: serializer.fromJson<String>(json['prestataireUid']),
      messageTexte: serializer.fromJson<String?>(json['messageTexte']),
      audioLocal: serializer.fromJson<String?>(json['audioLocal']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      audioDuree: serializer.fromJson<int>(json['audioDuree']),
      montant: serializer.fromJson<int>(json['montant']),
      statut: serializer.fromJson<String>(json['statut']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'clientTelephone': serializer.toJson<String>(clientTelephone),
      'prestataireUid': serializer.toJson<String>(prestataireUid),
      'messageTexte': serializer.toJson<String?>(messageTexte),
      'audioLocal': serializer.toJson<String?>(audioLocal),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'audioDuree': serializer.toJson<int>(audioDuree),
      'montant': serializer.toJson<int>(montant),
      'statut': serializer.toJson<String>(statut),
      'creeLe': serializer.toJson<DateTime>(creeLe),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CommandeLocale copyWith(
          {String? uid,
          String? clientTelephone,
          String? prestataireUid,
          Value<String?> messageTexte = const Value.absent(),
          Value<String?> audioLocal = const Value.absent(),
          Value<String?> audioUrl = const Value.absent(),
          int? audioDuree,
          int? montant,
          String? statut,
          DateTime? creeLe,
          DateTime? updatedAt}) =>
      CommandeLocale(
        uid: uid ?? this.uid,
        clientTelephone: clientTelephone ?? this.clientTelephone,
        prestataireUid: prestataireUid ?? this.prestataireUid,
        messageTexte:
            messageTexte.present ? messageTexte.value : this.messageTexte,
        audioLocal: audioLocal.present ? audioLocal.value : this.audioLocal,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
        audioDuree: audioDuree ?? this.audioDuree,
        montant: montant ?? this.montant,
        statut: statut ?? this.statut,
        creeLe: creeLe ?? this.creeLe,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CommandeLocale copyWithCompanion(CommandesCompanion data) {
    return CommandeLocale(
      uid: data.uid.present ? data.uid.value : this.uid,
      clientTelephone: data.clientTelephone.present
          ? data.clientTelephone.value
          : this.clientTelephone,
      prestataireUid: data.prestataireUid.present
          ? data.prestataireUid.value
          : this.prestataireUid,
      messageTexte: data.messageTexte.present
          ? data.messageTexte.value
          : this.messageTexte,
      audioLocal:
          data.audioLocal.present ? data.audioLocal.value : this.audioLocal,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      audioDuree:
          data.audioDuree.present ? data.audioDuree.value : this.audioDuree,
      montant: data.montant.present ? data.montant.value : this.montant,
      statut: data.statut.present ? data.statut.value : this.statut,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommandeLocale(')
          ..write('uid: $uid, ')
          ..write('clientTelephone: $clientTelephone, ')
          ..write('prestataireUid: $prestataireUid, ')
          ..write('messageTexte: $messageTexte, ')
          ..write('audioLocal: $audioLocal, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('audioDuree: $audioDuree, ')
          ..write('montant: $montant, ')
          ..write('statut: $statut, ')
          ..write('creeLe: $creeLe, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uid,
      clientTelephone,
      prestataireUid,
      messageTexte,
      audioLocal,
      audioUrl,
      audioDuree,
      montant,
      statut,
      creeLe,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandeLocale &&
          other.uid == this.uid &&
          other.clientTelephone == this.clientTelephone &&
          other.prestataireUid == this.prestataireUid &&
          other.messageTexte == this.messageTexte &&
          other.audioLocal == this.audioLocal &&
          other.audioUrl == this.audioUrl &&
          other.audioDuree == this.audioDuree &&
          other.montant == this.montant &&
          other.statut == this.statut &&
          other.creeLe == this.creeLe &&
          other.updatedAt == this.updatedAt);
}

class CommandesCompanion extends UpdateCompanion<CommandeLocale> {
  final Value<String> uid;
  final Value<String> clientTelephone;
  final Value<String> prestataireUid;
  final Value<String?> messageTexte;
  final Value<String?> audioLocal;
  final Value<String?> audioUrl;
  final Value<int> audioDuree;
  final Value<int> montant;
  final Value<String> statut;
  final Value<DateTime> creeLe;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CommandesCompanion({
    this.uid = const Value.absent(),
    this.clientTelephone = const Value.absent(),
    this.prestataireUid = const Value.absent(),
    this.messageTexte = const Value.absent(),
    this.audioLocal = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.audioDuree = const Value.absent(),
    this.montant = const Value.absent(),
    this.statut = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommandesCompanion.insert({
    required String uid,
    required String clientTelephone,
    required String prestataireUid,
    this.messageTexte = const Value.absent(),
    this.audioLocal = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.audioDuree = const Value.absent(),
    this.montant = const Value.absent(),
    this.statut = const Value.absent(),
    required DateTime creeLe,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        clientTelephone = Value(clientTelephone),
        prestataireUid = Value(prestataireUid),
        creeLe = Value(creeLe),
        updatedAt = Value(updatedAt);
  static Insertable<CommandeLocale> custom({
    Expression<String>? uid,
    Expression<String>? clientTelephone,
    Expression<String>? prestataireUid,
    Expression<String>? messageTexte,
    Expression<String>? audioLocal,
    Expression<String>? audioUrl,
    Expression<int>? audioDuree,
    Expression<int>? montant,
    Expression<String>? statut,
    Expression<DateTime>? creeLe,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (clientTelephone != null) 'client_telephone': clientTelephone,
      if (prestataireUid != null) 'prestataire_uid': prestataireUid,
      if (messageTexte != null) 'message_texte': messageTexte,
      if (audioLocal != null) 'audio_local': audioLocal,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (audioDuree != null) 'audio_duree': audioDuree,
      if (montant != null) 'montant': montant,
      if (statut != null) 'statut': statut,
      if (creeLe != null) 'cree_le': creeLe,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommandesCompanion copyWith(
      {Value<String>? uid,
      Value<String>? clientTelephone,
      Value<String>? prestataireUid,
      Value<String?>? messageTexte,
      Value<String?>? audioLocal,
      Value<String?>? audioUrl,
      Value<int>? audioDuree,
      Value<int>? montant,
      Value<String>? statut,
      Value<DateTime>? creeLe,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CommandesCompanion(
      uid: uid ?? this.uid,
      clientTelephone: clientTelephone ?? this.clientTelephone,
      prestataireUid: prestataireUid ?? this.prestataireUid,
      messageTexte: messageTexte ?? this.messageTexte,
      audioLocal: audioLocal ?? this.audioLocal,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuree: audioDuree ?? this.audioDuree,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      creeLe: creeLe ?? this.creeLe,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (clientTelephone.present) {
      map['client_telephone'] = Variable<String>(clientTelephone.value);
    }
    if (prestataireUid.present) {
      map['prestataire_uid'] = Variable<String>(prestataireUid.value);
    }
    if (messageTexte.present) {
      map['message_texte'] = Variable<String>(messageTexte.value);
    }
    if (audioLocal.present) {
      map['audio_local'] = Variable<String>(audioLocal.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (audioDuree.present) {
      map['audio_duree'] = Variable<int>(audioDuree.value);
    }
    if (montant.present) {
      map['montant'] = Variable<int>(montant.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommandesCompanion(')
          ..write('uid: $uid, ')
          ..write('clientTelephone: $clientTelephone, ')
          ..write('prestataireUid: $prestataireUid, ')
          ..write('messageTexte: $messageTexte, ')
          ..write('audioLocal: $audioLocal, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('audioDuree: $audioDuree, ')
          ..write('montant: $montant, ')
          ..write('statut: $statut, ')
          ..write('creeLe: $creeLe, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecherchesTable extends Recherches
    with TableInfo<$RecherchesTable, RechercheLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecherchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioLocalMeta =
      const VerificationMeta('audioLocal');
  @override
  late final GeneratedColumn<String> audioLocal = GeneratedColumn<String>(
      'audio_local', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transcriptionMeta =
      const VerificationMeta('transcription');
  @override
  late final GeneratedColumn<String> transcription = GeneratedColumn<String>(
      'transcription', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
      'cree_le', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uid, audioLocal, audioUrl, transcription, creeLe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recherches';
  @override
  VerificationContext validateIntegrity(Insertable<RechercheLocale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('audio_local')) {
      context.handle(
          _audioLocalMeta,
          audioLocal.isAcceptableOrUnknown(
              data['audio_local']!, _audioLocalMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    if (data.containsKey('transcription')) {
      context.handle(
          _transcriptionMeta,
          transcription.isAcceptableOrUnknown(
              data['transcription']!, _transcriptionMeta));
    }
    if (data.containsKey('cree_le')) {
      context.handle(_creeLeMeta,
          creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta));
    } else if (isInserting) {
      context.missing(_creeLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  RechercheLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RechercheLocale(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      audioLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_local']),
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
      transcription: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transcription']),
      creeLe: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cree_le'])!,
    );
  }

  @override
  $RecherchesTable createAlias(String alias) {
    return $RecherchesTable(attachedDatabase, alias);
  }
}

class RechercheLocale extends DataClass implements Insertable<RechercheLocale> {
  final String uid;
  final String? audioLocal;
  final String? audioUrl;
  final String? transcription;
  final DateTime creeLe;
  const RechercheLocale(
      {required this.uid,
      this.audioLocal,
      this.audioUrl,
      this.transcription,
      required this.creeLe});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    if (!nullToAbsent || audioLocal != null) {
      map['audio_local'] = Variable<String>(audioLocal);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    if (!nullToAbsent || transcription != null) {
      map['transcription'] = Variable<String>(transcription);
    }
    map['cree_le'] = Variable<DateTime>(creeLe);
    return map;
  }

  RecherchesCompanion toCompanion(bool nullToAbsent) {
    return RecherchesCompanion(
      uid: Value(uid),
      audioLocal: audioLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(audioLocal),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      transcription: transcription == null && nullToAbsent
          ? const Value.absent()
          : Value(transcription),
      creeLe: Value(creeLe),
    );
  }

  factory RechercheLocale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RechercheLocale(
      uid: serializer.fromJson<String>(json['uid']),
      audioLocal: serializer.fromJson<String?>(json['audioLocal']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      transcription: serializer.fromJson<String?>(json['transcription']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'audioLocal': serializer.toJson<String?>(audioLocal),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'transcription': serializer.toJson<String?>(transcription),
      'creeLe': serializer.toJson<DateTime>(creeLe),
    };
  }

  RechercheLocale copyWith(
          {String? uid,
          Value<String?> audioLocal = const Value.absent(),
          Value<String?> audioUrl = const Value.absent(),
          Value<String?> transcription = const Value.absent(),
          DateTime? creeLe}) =>
      RechercheLocale(
        uid: uid ?? this.uid,
        audioLocal: audioLocal.present ? audioLocal.value : this.audioLocal,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
        transcription:
            transcription.present ? transcription.value : this.transcription,
        creeLe: creeLe ?? this.creeLe,
      );
  RechercheLocale copyWithCompanion(RecherchesCompanion data) {
    return RechercheLocale(
      uid: data.uid.present ? data.uid.value : this.uid,
      audioLocal:
          data.audioLocal.present ? data.audioLocal.value : this.audioLocal,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      transcription: data.transcription.present
          ? data.transcription.value
          : this.transcription,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RechercheLocale(')
          ..write('uid: $uid, ')
          ..write('audioLocal: $audioLocal, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('transcription: $transcription, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, audioLocal, audioUrl, transcription, creeLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RechercheLocale &&
          other.uid == this.uid &&
          other.audioLocal == this.audioLocal &&
          other.audioUrl == this.audioUrl &&
          other.transcription == this.transcription &&
          other.creeLe == this.creeLe);
}

class RecherchesCompanion extends UpdateCompanion<RechercheLocale> {
  final Value<String> uid;
  final Value<String?> audioLocal;
  final Value<String?> audioUrl;
  final Value<String?> transcription;
  final Value<DateTime> creeLe;
  final Value<int> rowid;
  const RecherchesCompanion({
    this.uid = const Value.absent(),
    this.audioLocal = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.transcription = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecherchesCompanion.insert({
    required String uid,
    this.audioLocal = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.transcription = const Value.absent(),
    required DateTime creeLe,
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        creeLe = Value(creeLe);
  static Insertable<RechercheLocale> custom({
    Expression<String>? uid,
    Expression<String>? audioLocal,
    Expression<String>? audioUrl,
    Expression<String>? transcription,
    Expression<DateTime>? creeLe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (audioLocal != null) 'audio_local': audioLocal,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (transcription != null) 'transcription': transcription,
      if (creeLe != null) 'cree_le': creeLe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecherchesCompanion copyWith(
      {Value<String>? uid,
      Value<String?>? audioLocal,
      Value<String?>? audioUrl,
      Value<String?>? transcription,
      Value<DateTime>? creeLe,
      Value<int>? rowid}) {
    return RecherchesCompanion(
      uid: uid ?? this.uid,
      audioLocal: audioLocal ?? this.audioLocal,
      audioUrl: audioUrl ?? this.audioUrl,
      transcription: transcription ?? this.transcription,
      creeLe: creeLe ?? this.creeLe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (audioLocal.present) {
      map['audio_local'] = Variable<String>(audioLocal.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (transcription.present) {
      map['transcription'] = Variable<String>(transcription.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecherchesCompanion(')
          ..write('uid: $uid, ')
          ..write('audioLocal: $audioLocal, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('transcription: $transcription, ')
          ..write('creeLe: $creeLe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FileAttenteTable extends FileAttente
    with TableInfo<$FileAttenteTable, OperationFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileAttenteTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tableCibleMeta =
      const VerificationMeta('tableCible');
  @override
  late final GeneratedColumn<String> tableCible = GeneratedColumn<String>(
      'table_cible', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ligneIdMeta =
      const VerificationMeta('ligneId');
  @override
  late final GeneratedColumn<String> ligneId = GeneratedColumn<String>(
      'ligne_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
      'cree_le', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tentativesMeta =
      const VerificationMeta('tentatives');
  @override
  late final GeneratedColumn<int> tentatives = GeneratedColumn<int>(
      'tentatives', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, tableCible, ligneId, action, payload, creeLe, tentatives];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_attente';
  @override
  VerificationContext validateIntegrity(Insertable<OperationFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_cible')) {
      context.handle(
          _tableCibleMeta,
          tableCible.isAcceptableOrUnknown(
              data['table_cible']!, _tableCibleMeta));
    } else if (isInserting) {
      context.missing(_tableCibleMeta);
    }
    if (data.containsKey('ligne_id')) {
      context.handle(_ligneIdMeta,
          ligneId.isAcceptableOrUnknown(data['ligne_id']!, _ligneIdMeta));
    } else if (isInserting) {
      context.missing(_ligneIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('cree_le')) {
      context.handle(_creeLeMeta,
          creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta));
    } else if (isInserting) {
      context.missing(_creeLeMeta);
    }
    if (data.containsKey('tentatives')) {
      context.handle(
          _tentativesMeta,
          tentatives.isAcceptableOrUnknown(
              data['tentatives']!, _tentativesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationFile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tableCible: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}table_cible'])!,
      ligneId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ligne_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      creeLe: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cree_le'])!,
      tentatives: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tentatives'])!,
    );
  }

  @override
  $FileAttenteTable createAlias(String alias) {
    return $FileAttenteTable(attachedDatabase, alias);
  }
}

class OperationFile extends DataClass implements Insertable<OperationFile> {
  final String id;
  final String tableCible;
  final String ligneId;
  final String action;
  final String payload;
  final DateTime creeLe;
  final int tentatives;
  const OperationFile(
      {required this.id,
      required this.tableCible,
      required this.ligneId,
      required this.action,
      required this.payload,
      required this.creeLe,
      required this.tentatives});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_cible'] = Variable<String>(tableCible);
    map['ligne_id'] = Variable<String>(ligneId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['cree_le'] = Variable<DateTime>(creeLe);
    map['tentatives'] = Variable<int>(tentatives);
    return map;
  }

  FileAttenteCompanion toCompanion(bool nullToAbsent) {
    return FileAttenteCompanion(
      id: Value(id),
      tableCible: Value(tableCible),
      ligneId: Value(ligneId),
      action: Value(action),
      payload: Value(payload),
      creeLe: Value(creeLe),
      tentatives: Value(tentatives),
    );
  }

  factory OperationFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationFile(
      id: serializer.fromJson<String>(json['id']),
      tableCible: serializer.fromJson<String>(json['tableCible']),
      ligneId: serializer.fromJson<String>(json['ligneId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
      tentatives: serializer.fromJson<int>(json['tentatives']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tableCible': serializer.toJson<String>(tableCible),
      'ligneId': serializer.toJson<String>(ligneId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'creeLe': serializer.toJson<DateTime>(creeLe),
      'tentatives': serializer.toJson<int>(tentatives),
    };
  }

  OperationFile copyWith(
          {String? id,
          String? tableCible,
          String? ligneId,
          String? action,
          String? payload,
          DateTime? creeLe,
          int? tentatives}) =>
      OperationFile(
        id: id ?? this.id,
        tableCible: tableCible ?? this.tableCible,
        ligneId: ligneId ?? this.ligneId,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        creeLe: creeLe ?? this.creeLe,
        tentatives: tentatives ?? this.tentatives,
      );
  OperationFile copyWithCompanion(FileAttenteCompanion data) {
    return OperationFile(
      id: data.id.present ? data.id.value : this.id,
      tableCible:
          data.tableCible.present ? data.tableCible.value : this.tableCible,
      ligneId: data.ligneId.present ? data.ligneId.value : this.ligneId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
      tentatives:
          data.tentatives.present ? data.tentatives.value : this.tentatives,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationFile(')
          ..write('id: $id, ')
          ..write('tableCible: $tableCible, ')
          ..write('ligneId: $ligneId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('creeLe: $creeLe, ')
          ..write('tentatives: $tentatives')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tableCible, ligneId, action, payload, creeLe, tentatives);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationFile &&
          other.id == this.id &&
          other.tableCible == this.tableCible &&
          other.ligneId == this.ligneId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.creeLe == this.creeLe &&
          other.tentatives == this.tentatives);
}

class FileAttenteCompanion extends UpdateCompanion<OperationFile> {
  final Value<String> id;
  final Value<String> tableCible;
  final Value<String> ligneId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> creeLe;
  final Value<int> tentatives;
  final Value<int> rowid;
  const FileAttenteCompanion({
    this.id = const Value.absent(),
    this.tableCible = const Value.absent(),
    this.ligneId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.tentatives = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileAttenteCompanion.insert({
    required String id,
    required String tableCible,
    required String ligneId,
    required String action,
    required String payload,
    required DateTime creeLe,
    this.tentatives = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tableCible = Value(tableCible),
        ligneId = Value(ligneId),
        action = Value(action),
        payload = Value(payload),
        creeLe = Value(creeLe);
  static Insertable<OperationFile> custom({
    Expression<String>? id,
    Expression<String>? tableCible,
    Expression<String>? ligneId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? creeLe,
    Expression<int>? tentatives,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableCible != null) 'table_cible': tableCible,
      if (ligneId != null) 'ligne_id': ligneId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (creeLe != null) 'cree_le': creeLe,
      if (tentatives != null) 'tentatives': tentatives,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileAttenteCompanion copyWith(
      {Value<String>? id,
      Value<String>? tableCible,
      Value<String>? ligneId,
      Value<String>? action,
      Value<String>? payload,
      Value<DateTime>? creeLe,
      Value<int>? tentatives,
      Value<int>? rowid}) {
    return FileAttenteCompanion(
      id: id ?? this.id,
      tableCible: tableCible ?? this.tableCible,
      ligneId: ligneId ?? this.ligneId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      creeLe: creeLe ?? this.creeLe,
      tentatives: tentatives ?? this.tentatives,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tableCible.present) {
      map['table_cible'] = Variable<String>(tableCible.value);
    }
    if (ligneId.present) {
      map['ligne_id'] = Variable<String>(ligneId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    if (tentatives.present) {
      map['tentatives'] = Variable<int>(tentatives.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileAttenteCompanion(')
          ..write('id: $id, ')
          ..write('tableCible: $tableCible, ')
          ..write('ligneId: $ligneId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('creeLe: $creeLe, ')
          ..write('tentatives: $tentatives, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EtatSyncTable extends EtatSync
    with TableInfo<$EtatSyncTable, EtatLigne> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtatSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cleMeta = const VerificationMeta('cle');
  @override
  late final GeneratedColumn<String> cle = GeneratedColumn<String>(
      'cle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valeurMeta = const VerificationMeta('valeur');
  @override
  late final GeneratedColumn<String> valeur = GeneratedColumn<String>(
      'valeur', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cle, valeur];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etat_sync';
  @override
  VerificationContext validateIntegrity(Insertable<EtatLigne> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cle')) {
      context.handle(
          _cleMeta, cle.isAcceptableOrUnknown(data['cle']!, _cleMeta));
    } else if (isInserting) {
      context.missing(_cleMeta);
    }
    if (data.containsKey('valeur')) {
      context.handle(_valeurMeta,
          valeur.isAcceptableOrUnknown(data['valeur']!, _valeurMeta));
    } else if (isInserting) {
      context.missing(_valeurMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cle};
  @override
  EtatLigne map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EtatLigne(
      cle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cle'])!,
      valeur: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}valeur'])!,
    );
  }

  @override
  $EtatSyncTable createAlias(String alias) {
    return $EtatSyncTable(attachedDatabase, alias);
  }
}

class EtatLigne extends DataClass implements Insertable<EtatLigne> {
  final String cle;
  final String valeur;
  const EtatLigne({required this.cle, required this.valeur});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cle'] = Variable<String>(cle);
    map['valeur'] = Variable<String>(valeur);
    return map;
  }

  EtatSyncCompanion toCompanion(bool nullToAbsent) {
    return EtatSyncCompanion(
      cle: Value(cle),
      valeur: Value(valeur),
    );
  }

  factory EtatLigne.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EtatLigne(
      cle: serializer.fromJson<String>(json['cle']),
      valeur: serializer.fromJson<String>(json['valeur']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cle': serializer.toJson<String>(cle),
      'valeur': serializer.toJson<String>(valeur),
    };
  }

  EtatLigne copyWith({String? cle, String? valeur}) => EtatLigne(
        cle: cle ?? this.cle,
        valeur: valeur ?? this.valeur,
      );
  EtatLigne copyWithCompanion(EtatSyncCompanion data) {
    return EtatLigne(
      cle: data.cle.present ? data.cle.value : this.cle,
      valeur: data.valeur.present ? data.valeur.value : this.valeur,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EtatLigne(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cle, valeur);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EtatLigne &&
          other.cle == this.cle &&
          other.valeur == this.valeur);
}

class EtatSyncCompanion extends UpdateCompanion<EtatLigne> {
  final Value<String> cle;
  final Value<String> valeur;
  final Value<int> rowid;
  const EtatSyncCompanion({
    this.cle = const Value.absent(),
    this.valeur = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EtatSyncCompanion.insert({
    required String cle,
    required String valeur,
    this.rowid = const Value.absent(),
  })  : cle = Value(cle),
        valeur = Value(valeur);
  static Insertable<EtatLigne> custom({
    Expression<String>? cle,
    Expression<String>? valeur,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cle != null) 'cle': cle,
      if (valeur != null) 'valeur': valeur,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EtatSyncCompanion copyWith(
      {Value<String>? cle, Value<String>? valeur, Value<int>? rowid}) {
    return EtatSyncCompanion(
      cle: cle ?? this.cle,
      valeur: valeur ?? this.valeur,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cle.present) {
      map['cle'] = Variable<String>(cle.value);
    }
    if (valeur.present) {
      map['valeur'] = Variable<String>(valeur.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtatSyncCompanion(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrestatairesTable prestataires = $PrestatairesTable(this);
  late final $CommandesTable commandes = $CommandesTable(this);
  late final $RecherchesTable recherches = $RecherchesTable(this);
  late final $FileAttenteTable fileAttente = $FileAttenteTable(this);
  late final $EtatSyncTable etatSync = $EtatSyncTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [prestataires, commandes, recherches, fileAttente, etatSync];
}

typedef $$PrestatairesTableCreateCompanionBuilder = PrestatairesCompanion
    Function({
  required String uid,
  required String nom,
  required String categorie,
  required String quartier,
  Value<String> description,
  Value<int> prixBase,
  Value<String> photos,
  Value<String> tarifs,
  required String telephone,
  Value<String> statut,
  Value<int> vues,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PrestatairesTableUpdateCompanionBuilder = PrestatairesCompanion
    Function({
  Value<String> uid,
  Value<String> nom,
  Value<String> categorie,
  Value<String> quartier,
  Value<String> description,
  Value<int> prixBase,
  Value<String> photos,
  Value<String> tarifs,
  Value<String> telephone,
  Value<String> statut,
  Value<int> vues,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PrestatairesTableFilterComposer
    extends Composer<_$AppDatabase, $PrestatairesTable> {
  $$PrestatairesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quartier => $composableBuilder(
      column: $table.quartier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prixBase => $composableBuilder(
      column: $table.prixBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photos => $composableBuilder(
      column: $table.photos, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tarifs => $composableBuilder(
      column: $table.tarifs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vues => $composableBuilder(
      column: $table.vues, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PrestatairesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrestatairesTable> {
  $$PrestatairesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categorie => $composableBuilder(
      column: $table.categorie, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quartier => $composableBuilder(
      column: $table.quartier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prixBase => $composableBuilder(
      column: $table.prixBase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photos => $composableBuilder(
      column: $table.photos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tarifs => $composableBuilder(
      column: $table.tarifs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telephone => $composableBuilder(
      column: $table.telephone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vues => $composableBuilder(
      column: $table.vues, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PrestatairesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrestatairesTable> {
  $$PrestatairesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<String> get quartier =>
      $composableBuilder(column: $table.quartier, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get prixBase =>
      $composableBuilder(column: $table.prixBase, builder: (column) => column);

  GeneratedColumn<String> get photos =>
      $composableBuilder(column: $table.photos, builder: (column) => column);

  GeneratedColumn<String> get tarifs =>
      $composableBuilder(column: $table.tarifs, builder: (column) => column);

  GeneratedColumn<String> get telephone =>
      $composableBuilder(column: $table.telephone, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<int> get vues =>
      $composableBuilder(column: $table.vues, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PrestatairesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrestatairesTable,
    PrestataireLocal,
    $$PrestatairesTableFilterComposer,
    $$PrestatairesTableOrderingComposer,
    $$PrestatairesTableAnnotationComposer,
    $$PrestatairesTableCreateCompanionBuilder,
    $$PrestatairesTableUpdateCompanionBuilder,
    (
      PrestataireLocal,
      BaseReferences<_$AppDatabase, $PrestatairesTable, PrestataireLocal>
    ),
    PrestataireLocal,
    PrefetchHooks Function()> {
  $$PrestatairesTableTableManager(_$AppDatabase db, $PrestatairesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrestatairesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrestatairesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrestatairesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uid = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String> categorie = const Value.absent(),
            Value<String> quartier = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> prixBase = const Value.absent(),
            Value<String> photos = const Value.absent(),
            Value<String> tarifs = const Value.absent(),
            Value<String> telephone = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<int> vues = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PrestatairesCompanion(
            uid: uid,
            nom: nom,
            categorie: categorie,
            quartier: quartier,
            description: description,
            prixBase: prixBase,
            photos: photos,
            tarifs: tarifs,
            telephone: telephone,
            statut: statut,
            vues: vues,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uid,
            required String nom,
            required String categorie,
            required String quartier,
            Value<String> description = const Value.absent(),
            Value<int> prixBase = const Value.absent(),
            Value<String> photos = const Value.absent(),
            Value<String> tarifs = const Value.absent(),
            required String telephone,
            Value<String> statut = const Value.absent(),
            Value<int> vues = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PrestatairesCompanion.insert(
            uid: uid,
            nom: nom,
            categorie: categorie,
            quartier: quartier,
            description: description,
            prixBase: prixBase,
            photos: photos,
            tarifs: tarifs,
            telephone: telephone,
            statut: statut,
            vues: vues,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PrestatairesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrestatairesTable,
    PrestataireLocal,
    $$PrestatairesTableFilterComposer,
    $$PrestatairesTableOrderingComposer,
    $$PrestatairesTableAnnotationComposer,
    $$PrestatairesTableCreateCompanionBuilder,
    $$PrestatairesTableUpdateCompanionBuilder,
    (
      PrestataireLocal,
      BaseReferences<_$AppDatabase, $PrestatairesTable, PrestataireLocal>
    ),
    PrestataireLocal,
    PrefetchHooks Function()>;
typedef $$CommandesTableCreateCompanionBuilder = CommandesCompanion Function({
  required String uid,
  required String clientTelephone,
  required String prestataireUid,
  Value<String?> messageTexte,
  Value<String?> audioLocal,
  Value<String?> audioUrl,
  Value<int> audioDuree,
  Value<int> montant,
  Value<String> statut,
  required DateTime creeLe,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CommandesTableUpdateCompanionBuilder = CommandesCompanion Function({
  Value<String> uid,
  Value<String> clientTelephone,
  Value<String> prestataireUid,
  Value<String?> messageTexte,
  Value<String?> audioLocal,
  Value<String?> audioUrl,
  Value<int> audioDuree,
  Value<int> montant,
  Value<String> statut,
  Value<DateTime> creeLe,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CommandesTableFilterComposer
    extends Composer<_$AppDatabase, $CommandesTable> {
  $$CommandesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientTelephone => $composableBuilder(
      column: $table.clientTelephone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prestataireUid => $composableBuilder(
      column: $table.prestataireUid,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageTexte => $composableBuilder(
      column: $table.messageTexte, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioLocal => $composableBuilder(
      column: $table.audioLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get audioDuree => $composableBuilder(
      column: $table.audioDuree, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
      column: $table.creeLe, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CommandesTableOrderingComposer
    extends Composer<_$AppDatabase, $CommandesTable> {
  $$CommandesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientTelephone => $composableBuilder(
      column: $table.clientTelephone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prestataireUid => $composableBuilder(
      column: $table.prestataireUid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageTexte => $composableBuilder(
      column: $table.messageTexte,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioLocal => $composableBuilder(
      column: $table.audioLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get audioDuree => $composableBuilder(
      column: $table.audioDuree, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get montant => $composableBuilder(
      column: $table.montant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
      column: $table.creeLe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CommandesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommandesTable> {
  $$CommandesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get clientTelephone => $composableBuilder(
      column: $table.clientTelephone, builder: (column) => column);

  GeneratedColumn<String> get prestataireUid => $composableBuilder(
      column: $table.prestataireUid, builder: (column) => column);

  GeneratedColumn<String> get messageTexte => $composableBuilder(
      column: $table.messageTexte, builder: (column) => column);

  GeneratedColumn<String> get audioLocal => $composableBuilder(
      column: $table.audioLocal, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<int> get audioDuree => $composableBuilder(
      column: $table.audioDuree, builder: (column) => column);

  GeneratedColumn<int> get montant =>
      $composableBuilder(column: $table.montant, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CommandesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommandesTable,
    CommandeLocale,
    $$CommandesTableFilterComposer,
    $$CommandesTableOrderingComposer,
    $$CommandesTableAnnotationComposer,
    $$CommandesTableCreateCompanionBuilder,
    $$CommandesTableUpdateCompanionBuilder,
    (
      CommandeLocale,
      BaseReferences<_$AppDatabase, $CommandesTable, CommandeLocale>
    ),
    CommandeLocale,
    PrefetchHooks Function()> {
  $$CommandesTableTableManager(_$AppDatabase db, $CommandesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommandesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommandesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommandesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uid = const Value.absent(),
            Value<String> clientTelephone = const Value.absent(),
            Value<String> prestataireUid = const Value.absent(),
            Value<String?> messageTexte = const Value.absent(),
            Value<String?> audioLocal = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<int> audioDuree = const Value.absent(),
            Value<int> montant = const Value.absent(),
            Value<String> statut = const Value.absent(),
            Value<DateTime> creeLe = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommandesCompanion(
            uid: uid,
            clientTelephone: clientTelephone,
            prestataireUid: prestataireUid,
            messageTexte: messageTexte,
            audioLocal: audioLocal,
            audioUrl: audioUrl,
            audioDuree: audioDuree,
            montant: montant,
            statut: statut,
            creeLe: creeLe,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uid,
            required String clientTelephone,
            required String prestataireUid,
            Value<String?> messageTexte = const Value.absent(),
            Value<String?> audioLocal = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<int> audioDuree = const Value.absent(),
            Value<int> montant = const Value.absent(),
            Value<String> statut = const Value.absent(),
            required DateTime creeLe,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CommandesCompanion.insert(
            uid: uid,
            clientTelephone: clientTelephone,
            prestataireUid: prestataireUid,
            messageTexte: messageTexte,
            audioLocal: audioLocal,
            audioUrl: audioUrl,
            audioDuree: audioDuree,
            montant: montant,
            statut: statut,
            creeLe: creeLe,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CommandesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CommandesTable,
    CommandeLocale,
    $$CommandesTableFilterComposer,
    $$CommandesTableOrderingComposer,
    $$CommandesTableAnnotationComposer,
    $$CommandesTableCreateCompanionBuilder,
    $$CommandesTableUpdateCompanionBuilder,
    (
      CommandeLocale,
      BaseReferences<_$AppDatabase, $CommandesTable, CommandeLocale>
    ),
    CommandeLocale,
    PrefetchHooks Function()>;
typedef $$RecherchesTableCreateCompanionBuilder = RecherchesCompanion Function({
  required String uid,
  Value<String?> audioLocal,
  Value<String?> audioUrl,
  Value<String?> transcription,
  required DateTime creeLe,
  Value<int> rowid,
});
typedef $$RecherchesTableUpdateCompanionBuilder = RecherchesCompanion Function({
  Value<String> uid,
  Value<String?> audioLocal,
  Value<String?> audioUrl,
  Value<String?> transcription,
  Value<DateTime> creeLe,
  Value<int> rowid,
});

class $$RecherchesTableFilterComposer
    extends Composer<_$AppDatabase, $RecherchesTable> {
  $$RecherchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioLocal => $composableBuilder(
      column: $table.audioLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcription => $composableBuilder(
      column: $table.transcription, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
      column: $table.creeLe, builder: (column) => ColumnFilters(column));
}

class $$RecherchesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecherchesTable> {
  $$RecherchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioLocal => $composableBuilder(
      column: $table.audioLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcription => $composableBuilder(
      column: $table.transcription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
      column: $table.creeLe, builder: (column) => ColumnOrderings(column));
}

class $$RecherchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecherchesTable> {
  $$RecherchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get audioLocal => $composableBuilder(
      column: $table.audioLocal, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get transcription => $composableBuilder(
      column: $table.transcription, builder: (column) => column);

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);
}

class $$RecherchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecherchesTable,
    RechercheLocale,
    $$RecherchesTableFilterComposer,
    $$RecherchesTableOrderingComposer,
    $$RecherchesTableAnnotationComposer,
    $$RecherchesTableCreateCompanionBuilder,
    $$RecherchesTableUpdateCompanionBuilder,
    (
      RechercheLocale,
      BaseReferences<_$AppDatabase, $RecherchesTable, RechercheLocale>
    ),
    RechercheLocale,
    PrefetchHooks Function()> {
  $$RecherchesTableTableManager(_$AppDatabase db, $RecherchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecherchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecherchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecherchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uid = const Value.absent(),
            Value<String?> audioLocal = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String?> transcription = const Value.absent(),
            Value<DateTime> creeLe = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecherchesCompanion(
            uid: uid,
            audioLocal: audioLocal,
            audioUrl: audioUrl,
            transcription: transcription,
            creeLe: creeLe,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uid,
            Value<String?> audioLocal = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String?> transcription = const Value.absent(),
            required DateTime creeLe,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecherchesCompanion.insert(
            uid: uid,
            audioLocal: audioLocal,
            audioUrl: audioUrl,
            transcription: transcription,
            creeLe: creeLe,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecherchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecherchesTable,
    RechercheLocale,
    $$RecherchesTableFilterComposer,
    $$RecherchesTableOrderingComposer,
    $$RecherchesTableAnnotationComposer,
    $$RecherchesTableCreateCompanionBuilder,
    $$RecherchesTableUpdateCompanionBuilder,
    (
      RechercheLocale,
      BaseReferences<_$AppDatabase, $RecherchesTable, RechercheLocale>
    ),
    RechercheLocale,
    PrefetchHooks Function()>;
typedef $$FileAttenteTableCreateCompanionBuilder = FileAttenteCompanion
    Function({
  required String id,
  required String tableCible,
  required String ligneId,
  required String action,
  required String payload,
  required DateTime creeLe,
  Value<int> tentatives,
  Value<int> rowid,
});
typedef $$FileAttenteTableUpdateCompanionBuilder = FileAttenteCompanion
    Function({
  Value<String> id,
  Value<String> tableCible,
  Value<String> ligneId,
  Value<String> action,
  Value<String> payload,
  Value<DateTime> creeLe,
  Value<int> tentatives,
  Value<int> rowid,
});

class $$FileAttenteTableFilterComposer
    extends Composer<_$AppDatabase, $FileAttenteTable> {
  $$FileAttenteTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tableCible => $composableBuilder(
      column: $table.tableCible, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ligneId => $composableBuilder(
      column: $table.ligneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
      column: $table.creeLe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tentatives => $composableBuilder(
      column: $table.tentatives, builder: (column) => ColumnFilters(column));
}

class $$FileAttenteTableOrderingComposer
    extends Composer<_$AppDatabase, $FileAttenteTable> {
  $$FileAttenteTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tableCible => $composableBuilder(
      column: $table.tableCible, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ligneId => $composableBuilder(
      column: $table.ligneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
      column: $table.creeLe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tentatives => $composableBuilder(
      column: $table.tentatives, builder: (column) => ColumnOrderings(column));
}

class $$FileAttenteTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileAttenteTable> {
  $$FileAttenteTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tableCible => $composableBuilder(
      column: $table.tableCible, builder: (column) => column);

  GeneratedColumn<String> get ligneId =>
      $composableBuilder(column: $table.ligneId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);

  GeneratedColumn<int> get tentatives => $composableBuilder(
      column: $table.tentatives, builder: (column) => column);
}

class $$FileAttenteTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FileAttenteTable,
    OperationFile,
    $$FileAttenteTableFilterComposer,
    $$FileAttenteTableOrderingComposer,
    $$FileAttenteTableAnnotationComposer,
    $$FileAttenteTableCreateCompanionBuilder,
    $$FileAttenteTableUpdateCompanionBuilder,
    (
      OperationFile,
      BaseReferences<_$AppDatabase, $FileAttenteTable, OperationFile>
    ),
    OperationFile,
    PrefetchHooks Function()> {
  $$FileAttenteTableTableManager(_$AppDatabase db, $FileAttenteTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileAttenteTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FileAttenteTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FileAttenteTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tableCible = const Value.absent(),
            Value<String> ligneId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> creeLe = const Value.absent(),
            Value<int> tentatives = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FileAttenteCompanion(
            id: id,
            tableCible: tableCible,
            ligneId: ligneId,
            action: action,
            payload: payload,
            creeLe: creeLe,
            tentatives: tentatives,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tableCible,
            required String ligneId,
            required String action,
            required String payload,
            required DateTime creeLe,
            Value<int> tentatives = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FileAttenteCompanion.insert(
            id: id,
            tableCible: tableCible,
            ligneId: ligneId,
            action: action,
            payload: payload,
            creeLe: creeLe,
            tentatives: tentatives,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FileAttenteTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FileAttenteTable,
    OperationFile,
    $$FileAttenteTableFilterComposer,
    $$FileAttenteTableOrderingComposer,
    $$FileAttenteTableAnnotationComposer,
    $$FileAttenteTableCreateCompanionBuilder,
    $$FileAttenteTableUpdateCompanionBuilder,
    (
      OperationFile,
      BaseReferences<_$AppDatabase, $FileAttenteTable, OperationFile>
    ),
    OperationFile,
    PrefetchHooks Function()>;
typedef $$EtatSyncTableCreateCompanionBuilder = EtatSyncCompanion Function({
  required String cle,
  required String valeur,
  Value<int> rowid,
});
typedef $$EtatSyncTableUpdateCompanionBuilder = EtatSyncCompanion Function({
  Value<String> cle,
  Value<String> valeur,
  Value<int> rowid,
});

class $$EtatSyncTableFilterComposer
    extends Composer<_$AppDatabase, $EtatSyncTable> {
  $$EtatSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cle => $composableBuilder(
      column: $table.cle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valeur => $composableBuilder(
      column: $table.valeur, builder: (column) => ColumnFilters(column));
}

class $$EtatSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $EtatSyncTable> {
  $$EtatSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cle => $composableBuilder(
      column: $table.cle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valeur => $composableBuilder(
      column: $table.valeur, builder: (column) => ColumnOrderings(column));
}

class $$EtatSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $EtatSyncTable> {
  $$EtatSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cle =>
      $composableBuilder(column: $table.cle, builder: (column) => column);

  GeneratedColumn<String> get valeur =>
      $composableBuilder(column: $table.valeur, builder: (column) => column);
}

class $$EtatSyncTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EtatSyncTable,
    EtatLigne,
    $$EtatSyncTableFilterComposer,
    $$EtatSyncTableOrderingComposer,
    $$EtatSyncTableAnnotationComposer,
    $$EtatSyncTableCreateCompanionBuilder,
    $$EtatSyncTableUpdateCompanionBuilder,
    (EtatLigne, BaseReferences<_$AppDatabase, $EtatSyncTable, EtatLigne>),
    EtatLigne,
    PrefetchHooks Function()> {
  $$EtatSyncTableTableManager(_$AppDatabase db, $EtatSyncTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EtatSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EtatSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EtatSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cle = const Value.absent(),
            Value<String> valeur = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EtatSyncCompanion(
            cle: cle,
            valeur: valeur,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cle,
            required String valeur,
            Value<int> rowid = const Value.absent(),
          }) =>
              EtatSyncCompanion.insert(
            cle: cle,
            valeur: valeur,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EtatSyncTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EtatSyncTable,
    EtatLigne,
    $$EtatSyncTableFilterComposer,
    $$EtatSyncTableOrderingComposer,
    $$EtatSyncTableAnnotationComposer,
    $$EtatSyncTableCreateCompanionBuilder,
    $$EtatSyncTableUpdateCompanionBuilder,
    (EtatLigne, BaseReferences<_$AppDatabase, $EtatSyncTable, EtatLigne>),
    EtatLigne,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrestatairesTableTableManager get prestataires =>
      $$PrestatairesTableTableManager(_db, _db.prestataires);
  $$CommandesTableTableManager get commandes =>
      $$CommandesTableTableManager(_db, _db.commandes);
  $$RecherchesTableTableManager get recherches =>
      $$RecherchesTableTableManager(_db, _db.recherches);
  $$FileAttenteTableTableManager get fileAttente =>
      $$FileAttenteTableTableManager(_db, _db.fileAttente);
  $$EtatSyncTableTableManager get etatSync =>
      $$EtatSyncTableTableManager(_db, _db.etatSync);
}
