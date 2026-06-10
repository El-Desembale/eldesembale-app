import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

String normalizeSupportPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length > 10) return digits.substring(digits.length - 10);
  return digits;
}

String supportThreadIdFromPhone(String phone) {
  final normalized = normalizeSupportPhone(phone);
  return normalized.isEmpty ? 'anon' : normalized;
}

class SupportAttachmentModel {
  final String name;
  final String url;
  final String contentType;
  final int size;
  final String kind;

  const SupportAttachmentModel({
    required this.name,
    required this.url,
    required this.contentType,
    required this.size,
    required this.kind,
  });

  factory SupportAttachmentModel.fromMap(Map<String, dynamic> data) {
    final contentType = data['contentType'] as String? ?? '';
    return SupportAttachmentModel(
      name: data['name'] as String? ?? 'Adjunto',
      url: data['url'] as String? ?? '',
      contentType: contentType,
      size: (data['size'] as num?)?.toInt() ?? 0,
      kind: data['kind'] as String? ?? (contentType.startsWith('image/') ? 'image' : 'file'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'contentType': contentType,
      'size': size,
      'kind': kind,
    };
  }
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
  final List<SupportAttachmentModel> attachments;
  final String senderRole;
  final String senderName;
  final String source;
  final DateTime? createdAt;

  const SupportMessageModel({
    required this.id,
    required this.text,
    required this.attachments,
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
      attachments: ((data['attachments'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SupportAttachmentModel.fromMap)
          .where((attachment) => attachment.url.isNotEmpty)
          .toList(),
      senderRole: data['senderRole'] as String? ?? 'customer',
      senderName: data['senderName'] as String? ?? '',
      source: data['source'] as String? ?? 'mobile_app',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class SupportChatService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  SupportChatService(this._firestore, [FirebaseStorage? storage])
      : _storage = storage ?? FirebaseStorage.instance;

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
    String text = '',
    List<SupportAttachmentModel> attachments = const [],
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachments.isEmpty) return;
    await ensureThread(
      phone: phone,
      customerName: customerName,
      customerEmail: customerEmail,
    );
    final ref = _threadRef(phone);
    await ref.collection('messages').add({
      'text': trimmed,
      'attachments': attachments.map((attachment) => attachment.toMap()).toList(),
      'senderRole': 'customer',
      'senderName': customerName.isEmpty ? 'Cliente' : customerName,
      'source': 'mobile_app',
      'createdAt': FieldValue.serverTimestamp(),
    });
    final preview = trimmed.isNotEmpty ? trimmed : _attachmentPreview(attachments);
    await ref.update({
      'customerPhone': phone,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'sourcePlatforms': FieldValue.arrayUnion(['mobile_app']),
      'lastMessagePreview':
          preview.length > 160 ? preview.substring(0, 160) : preview,
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

  Future<SupportAttachmentModel> uploadAttachment({
    required String phone,
    required File file,
    required String fileName,
  }) async {
    final threadId = supportThreadIdFromPhone(phone);
    final sanitizedName = fileName.replaceAll(RegExp(r'[^\w.\-]+'), '_');
    final contentType = _contentTypeForName(fileName);
    final ref = _storage
        .ref()
        .child('support_attachments/$threadId/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName');
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putFile(file, metadata);
    final url = await ref.getDownloadURL();
    final size = await file.length();
    return SupportAttachmentModel(
      name: fileName,
      url: url,
      contentType: contentType,
      size: size,
      kind: contentType.startsWith('image/') ? 'image' : 'file',
    );
  }

  String _attachmentPreview(List<SupportAttachmentModel> attachments) {
    if (attachments.isEmpty) return '';
    if (attachments.length == 1) {
      return attachments.first.kind == 'image'
          ? 'Imagen adjunta'
          : 'Archivo adjunto: ${attachments.first.name}';
    }
    return '${attachments.length} archivos adjuntos';
  }

  String _contentTypeForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.doc')) return 'application/msword';
    if (lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (lower.endsWith('.txt')) return 'text/plain';
    return 'application/octet-stream';
  }
}
