import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:e_services_app/app/modules/requests/controllers/requests_controller.dart';
import 'package:e_services_app/app/modules/requests/models/request_model.dart';
import 'package:e_services_app/app/modules/requests/models/request_status.dart';
import 'package:e_services_app/app/widgets/pnu_loader.dart';
import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RequestsView extends GetView<RequestsController> {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final statuses = RequestStatus.values;
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final items = controller.requests;
      final error = controller.errorMessage.value;
      return CustomRefreshIndicator(
        onRefresh: controller.refresh,
        triggerMode: IndicatorTriggerMode.anywhere,
        offsetToArmed: 90,
        builder: (context, child, indicator) {
          final progress = indicator.value.clamp(0.0, 1.0);
          final translateY = 70 * progress;
          return Stack(
            children: [
              Positioned(
                top: 10 + translateY / 2 - 40,
                left: 0,
                right: 0,
                child: Opacity(opacity: progress, child: const PnuLoader(size: 80, logoSize: 50)),
              ),
              Transform.translate(offset: Offset(0, translateY), child: child),
            ],
          );
        },
        child: ListView(
          padding: AppSpacing.page,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _StatusChips(statuses: statuses, controller: controller),
            const SizedBox(height: 16),
            if (isLoading && items.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: PnuLoader(size: 120, logoSize: 60)),
            if (error != null && items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text(error, textAlign: TextAlign.center)),
              ),
            if (!isLoading && items.isEmpty && error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No requests yet.')),
              ),
            ...items.map((request) => _RequestCard(model: request)).toList(),
            if (isLoading && items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: PnuLoader(size: 80, logoSize: 40)),
              ),
          ],
        ),
      );
    });
  }
}

class _StatusChips extends StatelessWidget {
  final List<RequestStatus> statuses;
  final RequestsController controller;
  const _StatusChips({required this.statuses, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        final selected = controller.selectedStatus.value;
        return Row(
          children: statuses.map((status) {
            final bool active = status == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(status.label),
                selected: active,
                onSelected: (_) => controller.setStatus(status),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel model;
  const _RequestCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = _StatusVisual.fromLabel(model.remarks);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: visual.color, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    model.transactionId,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _StatusChip(label: visual.label, color: visual.color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              model.officeName ?? '—',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.75)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetaRow(
                    icon: Icons.access_time_rounded,
                    color: visual.color,
                    value: _formatDate(model.createdAt),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _MetaRow(
                    icon: Icons.money_rounded,
                    color: visual.color,
                    value: _formatAmount(model.amountToPay),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('MMM d • h:mm a').format(date);
  String _formatAmount(double value) {
    final formatted = value.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    return '₱$formatted';
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  const _MetaRow({required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusVisual {
  final String label;
  final Color color;
  const _StatusVisual(this.label, this.color);

  static _StatusVisual fromLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('pending')) return _StatusVisual(label, const Color(0xFFFFA500));
    if (normalized.contains('process')) return _StatusVisual(label, const Color(0xFF2563EB));
    if (normalized.contains('accept') || normalized.contains('paid')) {
      return _StatusVisual(label, const Color(0xFF10B981));
    }
    if (normalized.contains('declin') || normalized.contains('reject')) {
      return _StatusVisual(label, const Color(0xFFF97316));
    }
    if (normalized.contains('complete') || normalized.contains('done')) {
      return _StatusVisual(label, const Color(0xFF0EA5E9));
    }
    return _StatusVisual(label, const Color(0xFF64748B));
  }
}
