import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:e_services_app/app/config/theme/app_theme.dart';
import 'package:e_services_app/app/modules/home/controllers/home_controller.dart';
import 'package:e_services_app/app/modules/home/models/home_dashboard_models.dart';
import 'package:e_services_app/app/modules/requests/models/request_status.dart';
import 'package:e_services_app/app/widgets/pnu_loader.dart';
import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeDashboard extends GetView<HomeController> {
  final ValueChanged<RequestStatus>? onSummaryTap;
  const HomeDashboard({super.key, this.onSummaryTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.activeProfile.value == null) {
        return const PnuLoader();
      }

      if (controller.errorMessage.value != null && controller.activeProfile.value == null) {
        return _ErrorState(message: controller.errorMessage.value!, onRetry: controller.fetchDashboard);
      }

      final childScroll = NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final threshold = 200;
          final metrics = notification.metrics;
          if (controller.tabIndex.value == 0 &&
              controller.canLoadMoreTransactions &&
              metrics.maxScrollExtent > 0 &&
              metrics.pixels >= (metrics.maxScrollExtent - threshold)) {
            controller.loadMoreTransactions();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _ProfileHeader(controller: controller)),
            SliverToBoxAdapter(child: _TransactionFilters(controller: controller)),
            SliverToBoxAdapter(
              child: _RequestStats(controller: controller, onSummaryTap: onSummaryTap),
            ),
            SliverToBoxAdapter(child: _TabMenu(controller: controller)),
            SliverToBoxAdapter(child: _OfficeFilterDropdown(controller: controller)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final tab = controller.tabIndex.value;
                  return tab == 0 ? _TransactionList(controller: controller) : _PackageList(controller: controller);
                }),
              ),
            ),
          ],
        ),
      );

      return CustomRefreshIndicator(
        onRefresh: controller.refresh,
        triggerMode: IndicatorTriggerMode.onEdge,
        builder: (context, child, indicator) {
          final progress = indicator.value.clamp(0.0, 1.0);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 50,
                child: Opacity(opacity: progress, child: const PnuLoader(size: 70, logoSize: 36)),
              ),
              child,
            ],
          );
        },
        child: childScroll,
      );
    });
  }
}

class _ProfileHeader extends StatelessWidget {
  final HomeController controller;
  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.activeProfile.value;
      if (profile == null) return const SizedBox.shrink();
      final hasMultipleProfiles = controller.profiles.length > 1;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          24,
          60, // keep this as before so header bleeds into status bar
          24,
          hasMultipleProfiles ? 32 : 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.brandingPrimaryColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 25, offset: const Offset(0, 12))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text('Hello', style: AppTypography.title, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${_firstName(profile)}!',
                              style: AppTypography.authTitle.copyWith(color: Colors.white, fontSize: 24),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      _initials(profile),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Active Profile: ${profile.clientType}',
                    style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 14),
                  ),
                  if (hasMultipleProfiles)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.85)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _WeekCalendar(),
            if (hasMultipleProfiles) ...[const SizedBox(height: 18), _ProfileSwitcherChips(controller: controller)],
          ],
        ),
      );
    });
  }

  String _firstName(ProfileModel profile) {
    String first = profile.firstname.trim();
    if (first.isEmpty) {
      final parts = profile.displayName.split(' ').where((e) => e.trim().isNotEmpty).toList();
      first = parts.isNotEmpty ? parts.first : 'there';
    } else {
      first = first.split(' ').first;
    }
    return first.length <= 8 ? first : '${first.substring(0, 8)}…';
  }

  String _initials(ProfileModel profile) {
    final parts = [
      profile.firstname.trim(),
      profile.lastname.trim(),
    ].where((e) => e.isNotEmpty).map((e) => e[0]).toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.toUpperCase();
    return (parts[0] + parts[1]).toUpperCase();
  }
}

class _ProfileSwitcherChips extends StatelessWidget {
  final HomeController controller;
  const _ProfileSwitcherChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profiles = controller.profiles;
      if (profiles.length <= 1) return const SizedBox.shrink();
      final activeId = controller.activeProfile.value?.id;
      final switchingId = controller.switchingProfileId.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          height: 40,
          child: ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final selected = profile.id == activeId;
              final isLoading = switchingId == profile.id;
              return ChoiceChip(
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 0,
                side: BorderSide(color: Colors.white.withOpacity(selected ? 0.9 : 0.3)),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(profile.firstname, overflow: TextOverflow.ellipsis)),
                    if (isLoading) ...[
                      const SizedBox(width: 6),
                      const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ],
                ),
                selected: selected,
                selectedColor: Colors.white.withOpacity(0.2),
                backgroundColor: Colors.white.withOpacity(0.08),
                labelStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                onSelected: (_) => controller.selectProfile(profile),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: profiles.length,
          ),
        ),
      );
    });
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar();

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    final days = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final totalSpacing = spacing * (days.length - 1);
        final double rawWidth = (constraints.maxWidth - totalSpacing) / days.length;
        final double cardWidth = rawWidth.clamp(38.0, 60.0);

        return Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(days.length, (index) {
              final date = days[index];
              final bool isToday = date.day == today.day && date.month == today.month && date.year == today.year;
              final label = ['S', 'M', 'T', 'W', 'T', 'F', 'S'][date.weekday % 7];
              final Color baseColor = Colors.white.withOpacity(0.08);

              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(right: index == days.length - 1 ? 0 : spacing),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isToday ? Colors.white10 : baseColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(isToday ? 0.4 : 0.15)),
                ),
                child: Column(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: isToday ? Colors.white : Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: cardWidth * 0.7,
                      height: cardWidth * 0.7,
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFFFACC15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: GoogleFonts.poppins(
                            color: isToday ? AppColors.authHeaderStart : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _RequestStats extends StatelessWidget {
  final HomeController controller;
  final ValueChanged<RequestStatus>? onSummaryTap;
  const _RequestStats({required this.controller, this.onSummaryTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = controller.requestCounts.value;
      if (counts == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final tile = counts.tiles[index];
                  final color = _statColor(tile.label, index);
                  return _SummaryCard(
                    label: tile.label,
                    value: tile.value,
                    color: color,
                    onTap: () => onSummaryTap?.call(tile.status),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: counts.tiles.length,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final VoidCallback? onTap;
  const _SummaryCard({required this.label, required this.value, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    const double width = 220;
    final iconColor = color.darken(0.35);
    final labelColor = color.darken(0.5);
    final detailColor = color.darken(0.65);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: CustomPaint(
              painter: _SummaryWavePainter(baseColor: color),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.translate(
                          offset: const Offset(-4, 0),
                          child: Icon(Icons.folder_rounded, color: iconColor, size: 50),
                        ),
                        Icon(Icons.more_vert_rounded, color: iconColor.withOpacity(0.8), size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: GoogleFonts.poppins(color: labelColor, fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text('$value requests', style: GoogleFonts.poppins(color: detailColor, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabMenu extends StatelessWidget {
  final HomeController controller;
  const _TabMenu({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final idx = controller.tabIndex.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.78,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _TabButton(label: 'Transactions', selected: idx == 0, onTap: () => controller.selectTab(0)),
                        _TabButton(label: 'Packages', selected: idx == 1, onTap: () => controller.selectTab(1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Obx(() {
              return _FilterIconButton(
                icon: Icons.filter_alt_outlined,
                active: controller.showFilters.value,
                tooltip: 'Filter by office',
                onTap: controller.toggleFilters,
              );
            }),
          ],
        ),
      );
    });
  }
}

class _OfficeFilterDropdown extends StatelessWidget {
  final HomeController controller;
  const _OfficeFilterDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showFilters.value) return const SizedBox.shrink();
      final offices = controller.offices;
      final selected = controller.selectedOfficeId.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: DropdownButtonFormField<int?>(
          value: selected,
          decoration: const InputDecoration(labelText: 'Filter by office'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('ALL')),
            ...offices.map((office) => DropdownMenuItem<int?>(value: office.id, child: Text(office.description))),
          ],
          onChanged: controller.setOfficeFilter,
        ),
      );
    });
  }
}

class _TransactionFilters extends StatefulWidget {
  final HomeController controller;
  const _TransactionFilters({required this.controller});

  @override
  State<_TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends State<_TransactionFilters> {
  late final TextEditingController _searchCtrl;
  Worker? _searchWorker;

  HomeController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: controller.searchQuery.value);
    _searchWorker = ever<String>(controller.searchQuery, (value) {
      if (_searchCtrl.text != value) {
        _searchCtrl.text = value;
        _searchCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _searchCtrl.text.length));
      }
    });
  }

  @override
  void dispose() {
    _searchWorker?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: controller.setSearch,
        decoration: InputDecoration(
          hintText: 'Search transactions',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          filled: true,
          fillColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.15),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _FilterIconButton({required this.icon, required this.active, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = active ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color border = active ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;
    final Color fg = active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 16, semanticLabel: tooltip),
              const SizedBox(width: 6),
              Text(
                'Filter',
                style: theme.textTheme.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final HomeController controller;
  const _TransactionList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.paginatedTransactions;
      final hasMore = controller.canLoadMoreTransactions;
      if (controller.isLoading.value && items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (items.isEmpty) {
        return const _EmptyState(message: 'No transactions available for this profile yet.');
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = items[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == items.length - 1 && !hasMore ? 0 : 12),
            child: _TransactionCard(transaction: item),
          );
        },
      );
    });
  }
}

class _PackageList extends StatelessWidget {
  final HomeController controller;
  const _PackageList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.packages;
      if (controller.isLoading.value && items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (items.isEmpty) {
        return const _EmptyState(message: 'No packages available for this profile.');
      }
      return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => _PackageCard(package: items[index]),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      );
    });
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withOpacity(0.4);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandingPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (transaction.office != null)
                    Text(
                      'Office: ${transaction.office!.description}',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textApp),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    _formatAmount(transaction.amount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.brandingPrimaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _AddToCardIcon(color: AppColors.brandingPrimaryTextColor),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double value) =>
      '₱${value.toStringAsFixed(2).replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (match) => ',')}';
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;
  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withOpacity(0.4);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(package.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (package.office != null)
                    Text(
                      package.office!.description,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  if ((package.inclusions ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(package.inclusions!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _AddToCardIcon(color: theme.colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}

class _AddToCardIcon extends StatelessWidget {
  final Color color;
  const _AddToCardIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(CupertinoIcons.cart_badge_plus, color: color, size: 26);
  }
}

Color _statColor(String label, int index) {
  const palette = [
    Color(0xFFBDE1FF),
    Color(0xFFFDE1B7),
    Color(0xFFFAD5D8),
    Color(0xFFCCE9D3),
    Color(0xFFFFF3C7),
    Color(0xFFD4D7F5),
  ];
  return palette[index % palette.length];
}

extension _ColorShade on Color {
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color lighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

class _SummaryWavePainter extends CustomPainter {
  final Color baseColor;
  const _SummaryWavePainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = baseColor;
    final darkerPaint = Paint()..color = baseColor.darken(0.03);
    final highlightPaint = Paint()..color = baseColor.lighten(0.08).withOpacity(0.25);

    canvas.drawRect(Offset.zero & size, basePaint);

    final wavePath = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.7, size.width * 0.45, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.45, size.width, size.height * 0.62)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wavePath, darkerPaint);

    final highlightPath = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.55, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.4, size.width, size.height * 0.25)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandingPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? AppPalette.background : AppColors.textApp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 36, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function({int? userDataId, bool showLoader}) onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => onRetry(showLoader: true), child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
