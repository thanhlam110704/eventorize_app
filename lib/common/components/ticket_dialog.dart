import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';

class TicketDialog extends StatefulWidget {
  const TicketDialog({super.key});

  @override
  State<TicketDialog> createState() => _TicketDialogState();
}

class _TicketDialogState extends State<TicketDialog> {
  int nonMemberCount = 0;
  int vipCount = 1;
  final int vipPrice = 150000;

  @override
  Widget build(BuildContext context) {
    final total = vipCount * vipPrice;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "Tickets",
                        style: AppTextStyles.bold.copyWith(fontSize: 20),
                      ),
                      const Spacer(),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          border: Border.all(color: Color(0xFF9B9B9B)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 24, color: Colors.black),
                          padding: EdgeInsets.zero,
                          splashRadius: 20,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  buildTicketOption(
                    "Non - Member",
                    "Free\nSales end on Feb 26, 2025",
                    0,
                    nonMemberCount,
                    () => setState(() => nonMemberCount++),
                    () => setState(() => nonMemberCount = nonMemberCount > 0 ? nonMemberCount - 1 : 0),
                  ),
                  const SizedBox(height: 12),
                  buildTicketOption(
                    "VIP",
                    "150.000 VND",
                    vipPrice,
                    vipCount,
                    () => setState(() => vipCount++),
                    () => setState(() => vipCount = vipCount > 0 ? vipCount - 1 : 0),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: AppTextStyles.medium.copyWith(fontSize: 15),
                      ),
                      Text(
                        "${total.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")} VND",
                        style: AppTextStyles.medium.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFFEC0303),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      "Check out",
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTicketOption(
    String title,
    String subtitle,
    int price,
    int count,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
  ) {
    final parts = subtitle.split('\n');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.medium.copyWith(fontSize: 15),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7DCDC),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, size: 14),
                        color: const Color(0xFF9B9B9B),
                        onPressed: onDecrement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "$count",
                        style: AppTextStyles.medium.copyWith(fontSize: 15),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2176AE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, size: 14),
                        color: Colors.white,
                        onPressed: onIncrement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts[0],
                  style: AppTextStyles.medium.copyWith(fontSize: 15),
                ),
                if (parts.length > 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    parts[1],
                    style: AppTextStyles.text.copyWith(fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}