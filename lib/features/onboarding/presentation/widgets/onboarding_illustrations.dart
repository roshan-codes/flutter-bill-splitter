import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Step 1 Visual: Floating receipt card with 3 expense rows and floating group circle.
class OnboardingStep1Visual extends StatelessWidget {
  const OnboardingStep1Visual({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft lavender organic blob backdrop
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE).withOpacity(0.7),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),

          // Floating white receipt card
          Container(
            width: 210,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5F48E8).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Food & Drinks
                _buildExpenseRow(
                  icon: Icons.restaurant_rounded,
                  iconBg: const Color(0xFFF3F4F6),
                  titleWidth: 50,
                  subWidth: 32,
                  amount: '₹2,400',
                ),
                const SizedBox(height: 12),

                // Row 2: Hotel Stay
                _buildExpenseRow(
                  icon: Icons.hotel_rounded,
                  iconBg: const Color(0xFFF3F4F6),
                  titleWidth: 60,
                  subWidth: 40,
                  amount: '₹6,000',
                ),
                const SizedBox(height: 12),

                // Row 3: Fuel
                _buildExpenseRow(
                  icon: Icons.local_gas_station_rounded,
                  iconBg: const Color(0xFFF3F4F6),
                  titleWidth: 44,
                  subWidth: 28,
                  amount: '₹2,100',
                ),
              ],
            ),
          ),

          // Floating purple circle with group icon (bottom-right)
          Positioned(
            right: 22,
            bottom: 12,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C66FF), Color(0xFF5F48E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5F48E8).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.group_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow({
    required IconData icon,
    required Color iconBg,
    required double titleWidth,
    required double subWidth,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF1E1E1E)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: titleWidth,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: subWidth,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.manrope(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E1E1E),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

/// Step 2 Visual: Circular friends network with connected dashed line and purple checkmark.
class OnboardingStep2Visual extends StatelessWidget {
  const OnboardingStep2Visual({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft lavender blob backdrop
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE).withOpacity(0.7),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),

          // Dashed circular ring
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDDD5F8),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
          ),

          // Friend 1: Top avatar
          Positioned(
            top: 36,
            child: _buildAvatarCircle('assets/avatars/friend_1.png', 'A'),
          ),

          // Friend 2: Bottom-left avatar
          Positioned(
            left: 42,
            bottom: 60,
            child: _buildAvatarCircle('assets/avatars/friend_2.png', 'B'),
          ),

          // Friend 3: Bottom-right avatar
          Positioned(
            right: 42,
            bottom: 60,
            child: _buildAvatarCircle('assets/avatars/friend_3.png', 'C'),
          ),

          // Purple checkmark circle in center bottom
          Positioned(
            bottom: 42,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C66FF), Color(0xFF5F48E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5F48E8).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(String assetPath, String fallbackInitial) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF1E1E1E),
            child: Center(
              child: Text(
                fallbackInitial,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 3 Visual: "Settlement Complete!" card with celebration green badge and S -> R pill.
class OnboardingStep3Visual extends StatelessWidget {
  const OnboardingStep3Visual({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft lavender blob backdrop
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE).withOpacity(0.7),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),

          // Floating white settlement complete card
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5F48E8).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration circle with radiating rays
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Radial green ticks
                      const CustomPaint(
                        size: Size(50, 50),
                        painter: _CelebrationRaysPainter(),
                      ),
                      // Solid green circle with checkmark
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card title
                Text(
                  'Settlement Complete!',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 14),

                // S -> R settlement pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFF3F4F6), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // S circle (pink)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEECEB),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'S',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Arrow
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF1E1E1E),
                      ),
                      const SizedBox(width: 8),

                      // R circle (green)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F8EE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'R',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationRaysPainter extends CustomPainter {
  const _CelebrationRaysPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    // Draw 4 subtle tick marks around the circle
    canvas.drawLine(
        Offset(center.dx - 22, center.dy - 12),
        Offset(center.dx - 18, center.dy - 10),
        paint);
    canvas.drawLine(
        Offset(center.dx + 22, center.dy - 12),
        Offset(center.dx + 18, center.dy - 10),
        paint);
    canvas.drawLine(
        Offset(center.dx - 18, center.dy + 16),
        Offset(center.dx - 14, center.dy + 13),
        paint);
    canvas.drawLine(
        Offset(center.dx + 18, center.dy + 16),
        Offset(center.dx + 14, center.dy + 13),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
