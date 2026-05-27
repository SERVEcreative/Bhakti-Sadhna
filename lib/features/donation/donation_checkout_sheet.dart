import 'package:bhakti_sadhana/config/donation_config.dart';
import 'package:bhakti_sadhana/core/l10n/app_strings.dart';
import 'package:bhakti_sadhana/core/theme/bhakti_theme.dart';
import 'package:bhakti_sadhana/data/models/donation_cause.dart';
import 'package:bhakti_sadhana/services/monetization/upi_payment_qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  String get _transactionNote => widget.cause.title;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: BhaktiTheme.bodyHi)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
        child: Column(
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: BhaktiTheme.cardGradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: BhaktiTheme.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BhaktiTheme.saffron.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.cause.icon,
                      color: BhaktiTheme.goldLight,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cause.title,
                          style: BhaktiTheme.titleHi.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.cause.taglineHi,
                          style: BhaktiTheme.bodyHi.copyWith(
                            fontSize: 13,
                            color: BhaktiTheme.saffronLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.cause.description,
                          style: BhaktiTheme.labelSub.copyWith(
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (DonationConfig.hasUpi) ...[
              const SizedBox(height: 12),
              Text(
                'UPI: ${DonationConfig.upiId}',
                style: BhaktiTheme.labelSub.copyWith(
                  fontSize: 12,
                  color: BhaktiTheme.goldLight.withValues(alpha: 0.9),
                ),
              ),
            ],
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
            const SizedBox(height: 20),
            _DonationQrSection(
              amount: _amount,
              transactionNote: _transactionNote,
            ),
            const SizedBox(height: 16),
            if (DonationConfig.hasUpi)
              _ActionButton(
                label: AppStrings.donationCopyUpiId,
                icon: Icons.badge_rounded,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: DonationConfig.upiId));
                  _snack(AppStrings.donationUpiIdCopied);
                },
              ),
            const SizedBox(height: 10),
            _ActionButton(
              label: AppStrings.donationCopyDetails,
              icon: Icons.copy_rounded,
              onTap: () => _copyDetails(),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.donationCheckoutBlessing,
              textAlign: TextAlign.center,
              style: BhaktiTheme.titleHi.copyWith(
                fontSize: 14,
                color: BhaktiTheme.goldLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.donationDisclaimer,
              textAlign: TextAlign.center,
              style: BhaktiTheme.labelSub.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _copyDetails() {
    final amt = _amount;
    final buf = StringBuffer()
      ..writeln('दान विवरण')
      ..writeln('कारण: ${widget.cause.title}')
      ..writeln('विवरण: ${widget.cause.description}');
    if (amt != null && amt > 0) {
      buf.writeln('राशि: ₹$amt');
      if (DonationConfig.hasUpi) {
        buf.writeln('UPI QR: ${UpiPaymentQr.buildPayload(transactionNote: _transactionNote, amountInr: amt)}');
      }
    }
    buf.writeln('संस्था: ${DonationConfig.payeeName}');
    if (DonationConfig.hasUpi) buf.writeln('UPI: ${DonationConfig.upiId}');
    Clipboard.setData(ClipboardData(text: buf.toString()));
    Navigator.pop(context);
    _snack(AppStrings.donationCopied);
  }
}

class _DonationQrSection extends StatelessWidget {
  const _DonationQrSection({
    required this.amount,
    required this.transactionNote,
  });

  final int? amount;
  final String transactionNote;

  @override
  Widget build(BuildContext context) {
    final valid = amount != null && amount! > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: BhaktiTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppStrings.donationQrTitle,
              style: BhaktiTheme.titleHi.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            if (!valid)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 48,
                      color: BhaktiTheme.gold.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.donationQrSelectAmount,
                      textAlign: TextAlign.center,
                      style: BhaktiTheme.labelSub.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                '₹$amount • $transactionNote',
                textAlign: TextAlign.center,
                style: BhaktiTheme.bodyHi.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: UpiPaymentQr.buildPayload(
                    transactionNote: transactionNote,
                    amountInr: amount!,
                  ),
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.donationQrHint,
                textAlign: TextAlign.center,
                style: BhaktiTheme.labelSub.copyWith(fontSize: 12, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: BhaktiTheme.saffron.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BhaktiTheme.gold.withValues(alpha: 0.45)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: BhaktiTheme.goldLight, size: 22),
              const SizedBox(width: 8),
              Text(label, style: BhaktiTheme.titleHi.copyWith(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
