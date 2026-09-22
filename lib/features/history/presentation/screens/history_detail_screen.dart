import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../synchronization/data/local/app_database.dart';
import '../../../traveller/data/models/traveller.dart';
import '../../../../shared/providers/sync_provider.dart';
import '../../../../shared/providers/traveller_provider.dart';

/// Standalone read-only view of one past screening.
///
/// Deliberately SEPARATE from [TravellerRecordScreen]: that screen is step 1
/// of the live scanning flow (with nav cards + "Continue to Risk Assessment"
/// bottom bar). This page shows what was recorded for a history entry —
/// decision truth from the local database plus a traveller snapshot — with
/// no flow actions, so reviewing history can never disturb an in-progress
/// screening.
class HistoryDetailScreen extends ConsumerWidget {
  final String bookingReference;

  const HistoryDetailScreen({super.key, required this.bookingReference});

  StatusTone _toneFor(String decisionType) {
    switch (decisionType.toLowerCase()) {
      case 'cleared':
        return StatusTone.success;
      case 'referred':
        return StatusTone.info;
      case 'quarantined':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordStream = ref
        .watch(syncRepositoryProvider)
        .watchByBookingReference(bookingReference);

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Screening Record',
        subtitle: AfyaAppBar.shortRef(bookingReference),
      ),
      body: StreamBuilder<QueuedDecision?>(
        stream: recordStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(
                message: 'Loading screening record…');
          }
          final record = snapshot.data;
          if (record == null) {
            return AppErrorState(
              message:
                  'No stored screening found for "$bookingReference". It may have been removed from this device.',
              retryLabel: 'Back to history',
              onRetry: () => Navigator.of(context).pop(),
            );
          }
          return _recordBody(context, ref, record);
        },
      ),
    );
  }

  Widget _recordBody(
      BuildContext context, WidgetRef ref, QueuedDecision record) {
    final text = Theme.of(context).textTheme;
    final travellerAsync =
        ref.watch(travellerByReferenceProvider(bookingReference));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Recorded decision (local-database truth).
        const SectionHeader(title: 'Recorded decision'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusChip(
                      label: record.decisionType,
                      tone: _toneFor(record.decisionType),
                    ),
                    const Spacer(),
                    StatusChip(
                      label: record.synced ? 'Synced' : 'Saved on device',
                      tone: record.synced
                          ? StatusTone.success
                          : StatusTone.warning,
                      icon: record.synced
                          ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _row(context, 'Date / Time',
                    DateFormat('d MMM yyyy, HH:mm').format(record.timestamp)),
                const Divider(height: AppSpacing.lg),
                _row(context, 'Officer', record.officerName),
                const Divider(height: AppSpacing.lg),
                _row(context, 'Point of Entry', record.pointOfEntry),
                if (record.notes.isNotEmpty) ...[
                  const Divider(height: AppSpacing.lg),
                  Text('Officer notes', style: text.labelMedium),
                  const SizedBox(height: 4),
                  Text(record.notes, style: text.bodyMedium),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Traveller snapshot (read-only; no flow navigation).
        const SectionHeader(title: 'Traveller snapshot'),
        travellerAsync.when(
          loading: () => const AppLoadingState(
              message: 'Loading traveller details…'),
          error: (err, _) => AppErrorState(
            message: '$err',
            onRetry: () => ref.invalidate(
                travellerByReferenceProvider(bookingReference)),
          ),
          data: (traveller) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(context, traveller),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Identity'),
              _infoCard(context, [
                _row(context, 'Gender',
                    '${traveller.gender} · ${_age(traveller.dateOfBirth)}y'),
                _row(context, 'Date of Birth',
                    DateFormat('d MMM yyyy').format(traveller.dateOfBirth)),
                _row(context, 'Nationality', traveller.nationality),
                _row(context, 'Passport', traveller.passportId),
              ]),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Journey'),
              _infoCard(context, [
                _row(context, 'Booking Reference',
                    traveller.bookingReference),
                _row(
                    context,
                    'Arrival',
                    DateFormat('d MMM yyyy, HH:mm')
                        .format(traveller.arrivalDateTime)),
                _row(context, 'Point of Entry', traveller.pointOfEntry),
                _row(context, 'Transport', traveller.transportReference),
                if (traveller.originCountry != null)
                  _row(context, 'Journey Started',
                      traveller.originCountry!),
              ]),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Contact in Tanzania'),
              _infoCard(context, [
                if (traveller.physicalAddress != null)
                  _row(context, 'Address', traveller.physicalAddress!),
                if (traveller.hotelName != null)
                  _row(context, 'Hotel', traveller.hotelName!),
                _row(context, 'Phone', traveller.phoneNumber),
                if (traveller.email.isNotEmpty)
                  _row(context, 'Email', traveller.email),
              ]),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Travel history · 21 days'),
              _infoCard(context, [
                if (traveller.travelHistory.isEmpty)
                  _row(context, 'Countries', 'None recorded')
                else
                  for (final entry in traveller.travelHistory)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(entry.country,
                                style: text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (entry.period != null)
                            Flexible(
                              child: Text(entry.period!,
                                  textAlign: TextAlign.end,
                                  style: text.bodySmall),
                            ),
                        ],
                      ),
                    ),
              ]),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Health summary'),
              _healthSummary(context, traveller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileHeader(BuildContext context, Traveller traveller) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        InitialsAvatar(name: traveller.fullName, radius: 30),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(traveller.fullName, style: text.headlineSmall),
              const SizedBox(height: 4),
              Text(traveller.bookingReference,
                  style: text.titleSmall
                      ?.copyWith(letterSpacing: 0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(children: children),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthSummary(BuildContext context, Traveller traveller) {
    final screening = traveller.healthScreening;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (screening.symptoms.isEmpty)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.check_circle_outline,
                    color: AppStatus.success),
                title: Text('No symptoms reported'),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: screening.symptoms
                    .map((s) => StatusChip(
                          label: s,
                          tone: StatusTone.warning,
                          icon: Icons.warning_amber_outlined,
                        ))
                    .toList(),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                StatusChip(
                  label: screening.visitedOutbreakArea
                      ? 'Outbreak area: Yes'
                      : 'Outbreak area: No',
                  tone: screening.visitedOutbreakArea
                      ? StatusTone.danger
                      : StatusTone.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusChip(
                  label: screening.hasAnyExposure
                      ? 'Exposure reported'
                      : 'No exposure',
                  tone: screening.hasAnyExposure
                      ? StatusTone.danger
                      : StatusTone.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _age(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }
}
