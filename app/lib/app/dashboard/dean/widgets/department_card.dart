import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/app/core/constants/app_colors.dart';

class DeanDepartmentCard extends StatelessWidget {
  final String deptName;
  final String deptId;
  final int index;
  final bool useMargin;
  final VoidCallback? onTap;

  const DeanDepartmentCard({
    super.key,
    required this.deptName,
    required this.deptId,
    required this.index,
    this.useMargin = true,
    this.onTap,
  });

  Color _getGradientColor(int index) {
    return AppColors.gradientColors[index % AppColors.gradientColors.length];
  }

  Color _getLighterGradientColor(int index) {
    final baseColor = _getGradientColor(index);
    return Color.lerp(baseColor, Colors.white, 0.2)!;
  }

  @override
  Widget build(BuildContext context) {
    final gradientColor = _getGradientColor(index);

    return Container(
      margin: useMargin ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        shadowColor: gradientColor.withValues(alpha: 0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  gradientColor,
                  _getLighterGradientColor(index),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          deptName,
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'ID: $deptId',
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
