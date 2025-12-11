import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/app_state.dart';

class SubscriptionModal extends StatelessWidget {
  const SubscriptionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Your Plan',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildPlanCard(
                    context: context,
                    plan: 'basic',
                    name: 'Basic',
                    price: 'Free',
                    features: [
                      '50 searches/month',
                      'Basic AVM access',
                      'Property listings',
                      'Email support',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    context: context,
                    plan: 'pro',
                    name: 'Pro',
                    price: 'R499',
                    period: '/month',
                    popular: true,
                    features: [
                      'Unlimited searches',
                      'Advanced AVM',
                      'Lead alerts',
                      'Gated estate mapping',
                      'Priority support',
                      'Analytics dashboard',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    context: context,
                    plan: 'enterprise',
                    name: 'Enterprise',
                    price: 'R1,999',
                    period: '/month',
                    features: [
                      'Everything in Pro',
                      'API access',
                      'Bulk data exports',
                      'White-label option',
                      'Custom integrations',
                      'Dedicated account manager',
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String plan,
    required String name,
    required String price,
    String? period,
    bool popular = false,
    required List<String> features,
  }) {
    final appState = Provider.of<AppState>(context);
    final isCurrentPlan = appState.subscriptionPlan == plan;

    return Container(
      decoration: BoxDecoration(
        gradient: popular
            ? LinearGradient(
                colors: [AppColors.primaryRed, AppColors.darkRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: popular ? null : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: popular ? Colors.transparent : AppColors.border,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (popular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'MOST POPULAR',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkRed,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: popular ? Colors.white : AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: popular ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (period != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    period,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: popular ? AppColors.lightRed : AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: popular ? AppColors.accentYellow : AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: popular ? AppColors.lightRed : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan
                  ? null
                  : () {
                      appState.updateSubscription(plan);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched to $name plan!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: popular ? AppColors.accentYellow : AppColors.primaryRed,
                foregroundColor: popular ? AppColors.darkRed : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isCurrentPlan ? 'Current Plan' : 'Select Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
