import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:admin/ultils/fomatter/formatters.dart';

class UserModel {
  final String id;
  final Map<String, String> profile; // Thông tin cá nhân
  final Map<String, dynamic> contact; // Thông tin liên hệ
  final Map<String, dynamic> preferences; // Tùy chọn người dùng
  final Map<String, dynamic> metadata; // Thông tin bổ sung

  // Getters cho profile
  String get firstname => profile['firstname'] ?? '';
  String get lastname => profile['lastname'] ?? '';
  String get name => profile['name'] ?? '';
  String get gender => profile['gender'] ?? 'Nam';
  String get avatarUrl => profile['avatarUrl'] ?? '';
  String get profilePicture => profile['profilePicture'] ?? '';
  String get fullName => '$firstname $lastname'.trim();

  // Getters cho contact
  String? get email => contact['email'];
  String get phoneNumber => contact['phoneNumber'] ?? '';
  String get formatPhoneNumber => TFormatter.formatPhoneNumber(phoneNumber);

  // Getters cho địa chỉ
  List<Map<String, dynamic>> get addresses =>
      List<Map<String, dynamic>>.from(contact['addresses'] ?? []);

  Map<String, dynamic>? get defaultAddress {
    return addresses.firstWhere(
      (address) => address['isDefault'] == true,
      orElse: () => {},
    );
  }

  // Getters cho preferences
  List<String> get favorites =>
      List<String>.from(preferences['favorites'] ?? []);
  String get token => preferences['token'] ?? '';

  // Getters cho metadata
  Role get role => Role.values.firstWhere(
    (e) => e.name == (metadata['role'] ?? 'user'),
    orElse: () => Role.user,
  );
  DateTime get createdAt =>
      (metadata['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
  DateTime get dateOfBirth =>
      (metadata['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now();
  DateTime? get lastUpdated =>
      (metadata['lastUpdated'] as Timestamp?)?.toDate();

  const UserModel({
    required this.id,
    required this.profile,
    required this.contact,
    required this.preferences,
    required this.metadata,
  });

  // Helper methods cho tên người dùng
  static List<String> nameParts(String fullName) {
    if (fullName.isEmpty) return ['User', ''];

    List<String> parts = fullName.split(' ');
    if (parts.length == 1) return [parts[0], ''];

    return [parts[0], parts.sublist(1).join(' ')];
  }

  static String generateUserName(String fullName) {
    if (fullName.isEmpty) return 'cwt_user';

    List<String> parts = fullName.split(' ');
    String firstName = parts[0].toLowerCase();
    String lastName = parts.length > 1 ? parts.last.toLowerCase() : '';

    String camelCaseUserName =
        lastName.isEmpty ? firstName : '$firstName.$lastName';
    return 'cwt_$camelCaseUserName';
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      profile: Map<String, String>.from(
        map['profile'] ??
            {
              'name': '',
              'firstname': '',
              'lastname': '',
              'gender': 'Nam',
              'avatarUrl': '',
              'profilePicture': '',
            },
      ),
      contact: Map<String, dynamic>.from(
        map['contact'] ?? {'email': null, 'phoneNumber': '', 'addresses': []},
      ),
      preferences: Map<String, dynamic>.from(
        map['preferences'] ?? {'favorites': [], 'token': ''},
      ),
      metadata: Map<String, dynamic>.from(
        map['metadata'] ??
            {
              'role': 'user',
              'createdAt': Timestamp.now(),
              'dateOfBirth': Timestamp.now(),
              'lastUpdated': Timestamp.now(),
            },
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': profile,
      'contact': contact,
      'preferences': preferences,
      'metadata': {...metadata, 'lastUpdated': Timestamp.now()},
    };
  }

  UserModel copyWith({
    String? id,
    Map<String, String>? profile,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      contact: contact ?? this.contact,
      preferences: preferences ?? this.preferences,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper method cho hiển thị profile
  Map<String, dynamic> toProfileView() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': formatPhoneNumber,
      'avatar': avatarUrl,
      'defaultAddress': defaultAddress,
      'role': role.name,
    };
  }
}
