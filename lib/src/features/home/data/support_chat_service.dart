import 'package:cloud_firestore/cloud_firestore.dart';

String normalizeSupportPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length > 10) return digits.substring(digits.length - 10);
  return digits;
}

String supportThreadIdFromPhone(String phone) {
  final normalized = normalizeSupportPhone(phone);
  return normalized.isEmpty ? 'anon' : normalized;
}

class SupportThreadModel {
  final String id;
  final String customerPhone;
  final String customerName;
  final String customerEmail;
  final List<String> sourcePlatforms;
  final String lastMessagePreview;
  final DateTime? lastMessageAt;
  final int customerUnreadCount;

  const SupportThreadModel({
    required this.id,
    required this.customerPhone,
    required this.customerName,
    required this.customerEmail,
    required this.sourcePlatforms,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.customerUnreadCount,
  });

  factory SupportThreadModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return SupportThreadModel(
      id: doc.id,
      customerPhone: data['customerPhone'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      sourcePlatforms: ((data['sourcePlatforms'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      lastMessagePreview: data['lastMessagePreview'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      customerUnreadCount: (data['customerUnreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class SupportMessageModel {
  final String id;
  final String text;
  final String senderRole;
  final String senderName;
  final String source;
  final DateTime? createdAt;

  const SupportMessageModel({
    required this.id,
    required this.text,
    required this.senderRole,
    required this.senderName,
    required this.source,
    required this.createdAt,
  });

  factory SupportMessageModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return SupportMessageModel(
      id: doc.id,
      text: data['text'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? 'customer',
      senderName: data['senderName'] as String? ?? '',
      source: data['source'] as String? ?? 'mobile_app',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class SupportChatService {
  final FirebaseFirestore _firestore;

  SupportChatService(this._firestore);

  DocumentReference<Map<String, dynamic>> _threadRef(String phone) {
    return _firestore.collection('support_threads').doc(supportThreadIdFromPhone(phone));
  }

  Stream<SupportThreadModel?> watchThread(String phone) {
    return _threadRef(phone).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SupportThreadModel.fromFirestore(doc);
    });
  }

  Stream<List<SupportMessageModel>> watchMessages(String phone) {
    return _threadRef(phone)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(SupportMessageModel.fromFirestore).toList());
  }

  Future<void> ensureThread({
    required String phone,
    required String customerName,
    required String customerEmail,
  }) async {
    final ref = _threadRef(phone);
    final snap = await ref.get();
    await ref.set({
      'customerPhone': phone,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'sourcePlatforms': FieldValue.arrayUnion(['mobile_app']),
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendMessage({
    required String phone,
    required String customerName,
    required String customerEmail,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await ensureThread(
      phone: phone,
      customerName: customerName,
      customerEmail: customerEmail,
    );
    final ref = _threadRef(phone);
    await ref.collection('messages').add({
      'text': trimmed,
      'senderRole': 'customer',
      'senderName': customerName.isEmpty ? 'Cliente' : customerName,
      'source': 'mobile_app',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await ref.update({
      'customerPhone': phone,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'sourcePlatforms': FieldValue.arrayUnion(['mobile_app']),
      'lastMessagePreview': trimmed.length > 160 ? trimmed.substring(0, 160) : trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageBy': 'customer',
      'adminUnreadCount': FieldValue.increment(1),
      'customerUnreadCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markSeenByCustomer(String phone) async {
    final ref = _threadRef(phone);
    final snap = await ref.get();
    if (!snap.exists) return;
    await ref.set({
      'customerUnreadCount': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
