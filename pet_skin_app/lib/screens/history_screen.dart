import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _sortOrder = 'Newest';
  String _petFilter = 'All Pets';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const AppScaffold(
        showBack: true,
        child: Center(child: Text('Please sign in to view your history.')),
      );
    }

    return AppScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
            child: Text('Scan History', style: AppTextStyles.heading1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortOrder,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                        style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w600),
                        items: ['Newest', 'Oldest'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _sortOrder = v!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _petFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                        style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w600),
                        items: ['All Pets', 'Dog', 'Cat'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _petFilter = v!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.scanHistoryStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                var docs = snapshot.data?.docs ?? [];
                
                // Apply Pet Filter
                if (_petFilter != 'All Pets') {
                  docs = docs.where((doc) {
                    final pType = doc.data()['petType'] as String? ?? '';
                    return pType == _petFilter;
                  }).toList();
                }

                // Apply Sort Order (it comes Newest first by default from Firestore stream)
                if (_sortOrder == 'Oldest') {
                  docs = docs.reversed.toList();
                }

                if (docs.isEmpty) {
                  return _EmptyHistory();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return _ScanCard(data: data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scan History Card ────────────────────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ScanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final diagnosis = data['diagnosis'] as String? ?? 'Unknown';
    final confidence = ((data['confidence'] as num?)?.toDouble() ?? 0) * 100;
    final severity = data['severity'] as String? ?? '';
    final petType = data['petType'] as String? ?? 'Dog';
    final imageUrl = data['imageUrl'] as String? ?? '';
    final createdAt = data['createdAt'];
    String dateStr = '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      dateStr =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PlaceholderImage(),
                    )
                  : _PlaceholderImage(),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            diagnosis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SeverityBadge(severity: severity),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$petType  ·  ${confidence.toStringAsFixed(0)}% confidence',
                      style: AppTextStyles.caption,
                    ),
                    if (dateStr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 12, color: AppColors.textMedium),
                          const SizedBox(width: 4),
                          Text(dateStr, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMedium),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ScanDetailSheet(data: data),
    );
  }
}

// ─── Scan Detail Bottom Sheet ─────────────────────────────────────────────────
class _ScanDetailSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ScanDetailSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final diagnosis = data['diagnosis'] as String? ?? 'Unknown';
    final confidence = ((data['confidence'] as num?)?.toDouble() ?? 0) * 100;
    final severity = data['severity'] as String? ?? '';
    final urgency = data['urgency'] as String? ?? '';
    final description = data['description'] as String? ?? '';
    final treatments = List<String>.from(data['treatments'] as List? ?? []);
    final matched = List<String>.from(data['matchedSymptoms'] as List? ?? []);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(diagnosis, style: AppTextStyles.heading1),
            const SizedBox(height: 8),
            Row(children: [
              SeverityBadge(severity: severity),
              const SizedBox(width: 10),
              Text('${confidence.toStringAsFixed(0)}% confidence',
                  style: AppTextStyles.bodyBold),
            ]),
            const SizedBox(height: 16),
            if (description.isNotEmpty) ...[
              Text('About', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(description, style: AppTextStyles.body),
              const SizedBox(height: 16),
            ],
            if (urgency.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.schedule_rounded, color: Color(0xFFF57C00), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(urgency,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFF57C00)))),
                ]),
              ),
              const SizedBox(height: 16),
            ],
            if (matched.isNotEmpty) ...[
              Text('Matched Symptoms', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: matched.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.decorativeCircle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (treatments.isNotEmpty) ...[
              Text('Treatments', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              ...treatments.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(t, style: AppTextStyles.body)),
                ]),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No scans yet', style: AppTextStyles.heading2.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Complete your first diagnosis to see history here.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, height: 90,
      color: AppColors.decorativeCircle,
      child: const Icon(Icons.pets_rounded, color: AppColors.primary, size: 36),
    );
  }
}
