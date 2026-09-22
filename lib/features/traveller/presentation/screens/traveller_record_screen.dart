import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/utils/mask.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/providers/traveller_provider.dart';
import '../../data/models/traveller.dart';

class TravellerRecordScreen extends ConsumerStatefulWidget {
  final String bookingReference;

  const TravellerRecordScreen({super.key, required this.bookingReference});

  @override
  ConsumerState<TravellerRecordScreen> createState() =>
      _TravellerRecordScreenState();
}

class _TravellerRecordScreenState
    extends ConsumerState<TravellerRecordScreen> {
  bool _revealPassport = false;

  int _age(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _relativeArrival(DateTime arrival) {
    final diff = DateTime.now().difference(arrival);
    if (diff.isNegative) {
      final inHrs = diff.abs().inHours;
      if (inHrs < 1) return 'Arrives in ${diff.abs().inMinutes}m';
      if (inHrs < 24) return 'Arrives in ${inHrs}h';
      return 'Arrives in ${diff.abs().inDays}d';
    }
    if (diff.inMinutes < 60) return 'Landed ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Landed ${diff.inHours}h ago';
    return 'Landed ${diff.inDays}d ago';
  }

  IconData _transportIcon(String ref) {
    final v = ref.toLowerCase();
    if (v.contains('et ') ||
        v.contains('kq ') ||
        v.contains('qr') ||
        v.startsWith('et') && v.length < 8) {
      return Icons.flight_outlined;
    }
    if (v.contains('bus') || v.contains('coach')) {
      return Icons.directions_bus_outlined;
    }
    if (v.contains('boat') || v.contains('ferry') || v.contains('ship')) {
      return Icons.directions_boat_outlined;
    }
    return Icons.directions_car_outlined;
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final travellerAsync =
        ref.watch(travellerByReferenceProvider(widget.bookingReference));

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Traveller Record',
        subtitle:
            'Step 1 of 4 • ${AfyaAppBar.shortRef(widget.bookingReference)}',
      ),
      body: travellerAsync.when(
        loading: () =>
            const AppLoadingState(message: 'Retrieving traveller record…'),
        error: (err, _) => AppErrorState(
          message: '$err',
          onRetry: () => ref.invalidate(
              travellerByReferenceProvider(widget.bookingReference)),
        ),
        data: (traveller) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            child: Column(
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
                  _passportRow(context, traveller),
                ]),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Journey'),
                _infoCard(context, [
                  _copyRow(context, 'Booking Reference',
                      traveller.bookingReference),
                  _row(
                      context,
                      'Arrival',
                      '${DateFormat('d MMM yyyy, HH:mm').format(traveller.arrivalDateTime)}\n${_relativeArrival(traveller.arrivalDateTime)}'),
                  _row(context, 'Point of Entry', traveller.pointOfEntry),
                  if (traveller.transportReference.isNotEmpty)
                    _transportRow(context, traveller),
                  if (traveller.seatNumber != null)
                    _row(context, 'Seat Number', traveller.seatNumber!),
                  if (traveller.reasonForTravel != null)
                    _row(context, 'Reason for Travel',
                        traveller.reasonForTravel!),
                  if (traveller.durationOfStayDays != null)
                    _row(context, 'Duration of Stay',
                        '${traveller.durationOfStayDays} days'),
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
                  _copyRow(context, 'Phone', traveller.phoneNumber,
                      icon: Icons.call_outlined),
                  if (traveller.email.isNotEmpty)
                    _copyRow(context, 'Email', traveller.email,
                        icon: Icons.mail_outlined),
                ]),
                const SizedBox(height: AppSpacing.lg),
                _navCard(
                  context,
                  icon: Icons.luggage_outlined,
                  title: 'Travel History',
                  subtitle:
                      '${traveller.travelHistory.length} ${traveller.travelHistory.length == 1 ? 'country' : 'countries'} in the last 21 days',
                  onTap: () => context.push(AppRoutes.travelHistory,
                      extra: widget.bookingReference),
                ),
                const SizedBox(height: AppSpacing.sm),
                _navCard(
                  context,
                  icon: Icons.monitor_heart_outlined,
                  title: 'Health Screening',
                  subtitle: traveller.healthScreening.symptoms.isEmpty
                      ? 'No symptoms reported'
                      : '${traveller.healthScreening.symptomCount} symptom(s) · ${traveller.healthScreening.hasAnyExposure ? 'exposure reported' : 'no exposure'}',
                  trailing: traveller.healthScreening.symptoms.isEmpty &&
                          !traveller.healthScreening.hasAnyExposure
                      ? const StatusChip(
                          label: 'Clear', tone: StatusTone.success)
                      : const StatusChip(
                          label: 'Review', tone: StatusTone.warning),
                  onTap: () => context.push(AppRoutes.healthScreening,
                      extra: widget.bookingReference),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: travellerAsync.maybeWhen(
        data: (_) => SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step 1 of 4 • Traveller verification',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRoutes.riskAssessment,
                        extra: widget.bookingReference),
                    child: const Text('Continue to Risk Assessment'),
                  ),
                ),
              ],
            ),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _profileHeader(BuildContext context, Traveller traveller) {
    final text = Theme.of(context).textTheme;
    final needsReview = traveller.healthScreening.symptoms.isNotEmpty ||
        traveller.healthScreening.hasAnyExposure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InitialsAvatar(name: traveller.fullName, radius: 30),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(traveller.fullName, style: text.headlineSmall),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () =>
                        _copy('Booking reference', traveller.bookingReference),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          traveller.bookingReference,
                          style: text.titleSmall
                              ?.copyWith(letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.copy_outlined,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusChip(
              label:
                  '${traveller.gender} · ${_age(traveller.dateOfBirth)}y',
              tone: StatusTone.neutral,
              icon: Icons.person_outlined,
            ),
            StatusChip(
              label: traveller.nationality,
              tone: StatusTone.info,
              icon: Icons.flag_outlined,
            ),
            StatusChip(
              label: needsReview ? 'Needs review' : 'Clear',
              tone:
                  needsReview ? StatusTone.warning : StatusTone.success,
              icon: needsReview
                  ? Icons.warning_amber_outlined
                  : Icons.check_circle_outline,
            ),
            StatusChip(
              label: _relativeArrival(traveller.arrivalDateTime),
              tone: StatusTone.neutral,
              icon: Icons.schedule_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
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

  Widget _copyRow(BuildContext context, String label, String value,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _copy(label, value),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(icon ?? Icons.copy_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passportRow(BuildContext context, Traveller traveller) {
    final display = _revealPassport
        ? traveller.passportId
        : maskPassport(traveller.passportId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('Passport / ID',
                style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Text(
              display,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          InkWell(
            onTap: () =>
                setState(() => _revealPassport = !_revealPassport),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                  _revealPassport
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
          InkWell(
            onTap: () => _copy('Passport', traveller.passportId),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.copy_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transportRow(BuildContext context, Traveller traveller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text('Transport',
                style: Theme.of(context).textTheme.labelMedium),
          ),
          Icon(_transportIcon(traveller.transportReference),
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              traveller.transportReference,
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

  Widget _navCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          child: Icon(icon, color: colors.primary),
        ),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium),
        subtitle: Text(subtitle,
            style: Theme.of(context).textTheme.bodyMedium),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: AppSpacing.xs),
            ],
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
