import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class Faculty extends StatelessWidget {
  final String factName;
  final String factId;
  final int index;
  
  const Faculty({
    super.key,
    required this.factName,
    required this.factId,
    required this.index,
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
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        shadowColor: gradientColor.withValues(alpha: 0.3),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              Routes.DEPARTMENTS,
              arguments: {'factId': factId, 'factName': factName},
            );
          },
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
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          factName,
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'ID: $factId',
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
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
