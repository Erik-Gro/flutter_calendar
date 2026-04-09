import 'package:flutter/material.dart';
import 'package:flutter_calendar/controllers/themeController/theme_controller.dart';
import 'package:flutter_calendar/shared/consts/enums/app_theme.dart';
import 'package:flutter_calendar/shared/consts/classes/theme_manager.dart';

Future<void> showThemePickerBottomSheet(
  BuildContext context,
  ThemeController ctrl,
) {
  final theme = ThemeManager.getThemeData(ctrl.currentTheme);

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => ListenableBuilder(
      listenable: ctrl,
      builder: (ctx, _) {
        final currentTheme = ThemeManager.getThemeData(ctrl.currentTheme);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: currentTheme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: currentTheme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Design",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      const Text("Auto-Close", style: TextStyle(fontSize: 12)),
                      Switch(
                        value: ctrl.autoClosePreference,
                        onChanged: ctrl.setAutoClose,
                        activeThumbColor: currentTheme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppTheme.values.map((t) {
                  final isSel = t == ctrl.currentTheme;
                  final d = ThemeManager.themeDetails[t]!;
                  return InkWell(
                    onTap: () {
                      ctrl.setTheme(t);
                      if (ctrl.autoClosePreference) Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 95,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: currentTheme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSel
                              ? currentTheme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: d['color'],
                            radius: 18,
                            child: Icon(
                              d['icon'],
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            d['name'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: currentTheme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    ),
  );
}