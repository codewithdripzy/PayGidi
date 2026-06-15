import 'package:app/core/theme/pg_colors.dart';
// import 'package:app/core/theme/pg_styles.dart';
import 'package:app/core/widgets/pg_annotated_region.dart';
import 'package:app/core/widgets/pg_scale_button.dart';
import 'package:app/core/widgets/pg_texts.dart';
import 'package:app/features/home/presentation/screens/individual/individual_cards_screen.dart';
import 'package:app/features/home/presentation/screens/individual/individual_home_screen.dart';
import 'package:app/features/home/presentation/screens/individual/individual_me_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class IndividualMainScreen extends StatefulWidget {
  const IndividualMainScreen({super.key});

  @override
  State<IndividualMainScreen> createState() => _IndividualMainScreenState();
}

class _IndividualMainScreenState extends State<IndividualMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const IndividualHomeScreen(),
    const IndividualCardsScreen(),
    const Center(child: Text("Finance")),
    const IndividualMeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showPaymentSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PgTexts.text700(
                  context,
                  text: "Select Payment Type",
                  fontSize: 20,
                  color: PgColors.black,
                ),
                heightSpacing(24),
                _buildPaymentOption(
                  icon: Iconsax.send_1_copy,
                  title: "Instant Payment",
                  subtitle: "Send money instantly to anyone",
                  onTap: () {
                    Navigator.pop(context);
                    // Handle Instant Payment
                  },
                ),
                heightSpacing(16),
                _buildPaymentOption(
                  icon: Iconsax.link_1_copy,
                  title: "Payment Link",
                  subtitle: "Create a link to receive payments",
                  onTap: () {
                    Navigator.pop(context);
                    // Handle Payment Link
                  },
                ),
                heightSpacing(16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PgScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PgColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: PgColors.primary, size: 24),
            ),
            widthSpacing(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PgTexts.text600(
                    context,
                    text: title,
                    fontSize: 16,
                    color: PgColors.black,
                  ),
                  PgTexts.text400(
                    context,
                    text: subtitle,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: _buildPayButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Iconsax.home_2_copy, "Home"),
              _buildNavItem(1, Iconsax.card_copy, "Cards"),
              const SizedBox(width: 10), // Space for FAB
              _buildNavItem(2, Iconsax.chart_2_copy, "Finance"),
              _buildNavItem(3, Iconsax.user_copy, "Me"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return PgScaleButton(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? PgColors.primary : Colors.grey.shade400,
            size: 24,
          ),
          heightSpacing(4),
          PgTexts.text500(
            context,
            text: label,
            fontSize: 12,
            color: isSelected ? PgColors.primary : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return PgScaleButton(
      onTap: _showPaymentSelection,
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [PgColors.primary, PgColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: PgColors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/icons/pay_icon.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            height: 24,
          ),
        ),
      ),
    );
  }
}
