import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/dashboard_styles.dart';

class AdminSystemHealthSection extends StatelessWidget {
  const AdminSystemHealthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DashboardStyles.lightCardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub, color: AppColors.navy),
              const SizedBox(width: 12),
              Text(
                'System Health & Services',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _HealthRow(
            label: 'Background Services',
            status: 'Active',
            icon: Icons.settings_input_component,
            color: AppColors.success,
          ),
          const _HealthRow(
            label: 'Database Connector',
            status: 'Synchronized',
            icon: Icons.cloud_done,
            color: AppColors.success,
          ),
          const Divider(height: 32),
          Text(
            'Active Permissions',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PermissionChip(label: 'Microphone', icon: Icons.mic),
              _PermissionChip(label: 'Camera', icon: Icons.videocam),
              _PermissionChip(label: 'Phone', icon: Icons.phone),
              _PermissionChip(label: 'Storage', icon: Icons.folder),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.status,
    required this.icon,
    required this.color,
  });

  final String label;
  final String status;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.navy),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
