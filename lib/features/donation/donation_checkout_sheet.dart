import 'package:bhakti_sadhana/config/donation_config.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/donation_cause.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showDonationCheckoutSheet(BuildContext context, DonationCause cause) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BhaktiTheme.maroonDeep,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => _DonationCheckoutSheet(cause: cause),
  );
}

class _DonationCheckoutSheet extends StatefulWidget {
  const _DonationCheckoutSheet({required this.cause});

  final DonationCause cause;

  @override
  State<_DonationCheckoutSheet> createState() => _DonationCheckoutSheetState();
}

class _DonationCheckoutSheetState extends State<_DonationCheckoutSheet> {
  int? _selectedAmount;
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  int? get _amount {
    if (_customController.text.trim().isNotEmpty) {
      return int.tryParse(_customController.text.trim());
    }
    return _selectedAmount;
  }

  String get _note =>
      '${widget.cause.title} — ${DonationConfig.payeeName} — भक्ति साधना ऐप';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: BhaktiTheme.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BhaktiTheme.saffron.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.cause.icon, color: BhaktiTheme.goldLight),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.cause.title, style: BhaktiTheme.titleHi.copyWith(fontSize: 18)),
                    Text(
                      widget.cause.description,
                      style: BhaktiTheme.labelSub.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(AppStrings.donationAmount, style: BhaktiTheme.bodyHi.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DonationConfig.presetAmounts.map((amt) {
              final selected = _selectedAmount == amt && _customController.text.isEmpty;
              return ChoiceChip(
                label: Text('₹$amt'),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedAmount = amt;
                    _customController.clear();
                  });
                },
                selectedColor: BhaktiTheme.saffron,
                labelStyle: TextStyle(
                  color: selected ? BhaktiTheme.maroonDeep : BhaktiTheme.cream,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: BhaktiTheme.maroon.withValues(alpha: 0.6),
                side: BorderSide(color: BhaktiTheme.gold.withValues(alpha: 0.4)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: BhaktiTheme.bodyHi,
            decoration: InputDecoration(
              hintText: AppStrings.donationCustomAmount,
              hintStyle: BhaktiTheme.labelSub,
              filled: true,
              fillColor: BhaktiTheme.maroon.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: BhaktiTheme.gold.withValues(alpha: 0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: BhaktiTheme.gold.withValues(alpha: 0.35)),
              ),
              prefixText: '₹ ',
              prefixStyle: BhaktiTheme.titleHi.copyWith(color: BhaktiTheme.goldLight),
            ),
            onChanged: (_) => setState(() => _selectedAmount = null),
          ),
          const SizedBox(height: 18),
          _ActionButton(
            label: AppStrings.donationCopyDetails,
            icon: Icons.copy_rounded,
            onTap: () => _copyDetails(context),
          ),
          if (DonationConfig.hasUpi) ...[
            const SizedBox(height: 10),
            _ActionButton(
              label: AppStrings.donationUpi,
              icon: Icons.account_balance_wallet_rounded,
              filled: true,
              onTap: () => _copyUpi(context),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            AppStrings.donationDisclaimer,
            textAlign: TextAlign.center,
            style: BhaktiTheme.labelSub.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _copyDetails(BuildContext context) {
    final amt = _amount;
    final buf = StringBuffer()
      ..writeln('दान विवरण')
      ..writeln('कारण: ${widget.cause.title}')
      ..writeln('विवरण: ${widget.cause.description}');
    if (amt != null && amt > 0) buf.writeln('राशि: ₹$amt');
    buf.writeln('संस्था: ${DonationConfig.payeeName}');
  if (DonationConfig.hasUpi) buf.writeln('UPI: ${DonationConfig.upiId}');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.donationCopied, style: BhaktiTheme.bodyHi)),
    );
  }

  void _copyUpi(BuildContext context) {
    final amt = _amount ?? 0;
    final uri =
        'upi://pay?pa=${DonationConfig.upiId}&pn=${Uri.encodeComponent(DonationConfig.payeeName)}'
        '${amt > 0 ? '&am=$amt' : ''}&cu=INR&tn=${Uri.encodeComponent(widget.cause.title)}';
    Clipboard.setData(ClipboardData(text: uri));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.donationUpiCopied, style: BhaktiTheme.bodyHi)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: filled ? BhaktiTheme.goldShimmer : null,
            color: filled ? null : BhaktiTheme.saffron.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.45)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: BhaktiTheme.maroonDeep, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: BhaktiTheme.titleHi.copyWith(
                  fontSize: 16,
                  color: BhaktiTheme.maroonDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
