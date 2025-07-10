import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/user_view_model/event_detail_view_model.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:go_router/go_router.dart';
import 'package:eventorize_app/features/auth/user_view_model/check_out_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TicketDialog extends StatefulWidget {
  final String eventId;

  const TicketDialog({super.key, required this.eventId});

  @override
  State<TicketDialog> createState() => _TicketDialogState();
}

class _TicketDialogState extends State<TicketDialog> {
  Map<String, int> ticketCounts = {};
  Map<String, TextEditingController> ticketControllers = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<EventDetailViewModel>(context, listen: false)
            .fetchEventTickets(widget.eventId);
      }
    });
  }

  @override
  void dispose() {
    ticketControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoadingTickets) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            insetPadding: const EdgeInsets.all(16),
            child: const SizedBox(
              height: 200,
              child: Center(
                child: SpinKitFadingCircle(
                  color: AppColors.primary,
                  size: 50,
                ),
              ),
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  viewModel.errorMessage!,
                  style: AppTextStyles.text.copyWith(color: Colors.red),
                ),
              ),
            ),
          );
        }

        final tickets = viewModel.tickets;
        if (tickets.isEmpty) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350, minHeight: 180, maxHeight: 200),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 24, color: Colors.black),
                          padding: EdgeInsets.zero,
                          splashRadius: 20,
                          onPressed: () {
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Color(0xFF9B9B9B),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: Text(
                        "Không có vé khả dụng",
                        style: AppTextStyles.text.copyWith(fontSize: 16, color: Color(0xFF616161)),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        for (var ticket in tickets) {
          ticketCounts.putIfAbsent(ticket.id, () => 0);
          ticketControllers.putIfAbsent(
            ticket.id,
            () => TextEditingController(text: '${ticketCounts[ticket.id]}'),
          );
        }

        final total = tickets.fold<int>(
          0,
          (sum, ticket) => sum + (ticketCounts[ticket.id]! * ticket.price),
        );

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
                            "Chọn vé",
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
                              onPressed: () {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...tickets.map((ticket) => Column(
                            children: [
                              buildTicketOption(
                                ticket.title,
                                ticket.price == 0
                                    ? 'Miễn phí'
                                    : '${ticket.price.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")} VND',
                                ticket.price,
                                ticketCounts[ticket.id]!,
                                () {
                                  setState(() {
                                    ticketCounts[ticket.id] = ticketCounts[ticket.id]! + 1;
                                    ticketControllers[ticket.id]!.text = '${ticketCounts[ticket.id]}';
                                  });
                                },
                                () {
                                  setState(() {
                                    ticketCounts[ticket.id] = ticketCounts[ticket.id]! > 0 ? ticketCounts[ticket.id]! - 1 : 0;
                                    ticketControllers[ticket.id]!.text = '${ticketCounts[ticket.id]}';
                                  });
                                },
                                (value) {
                                  setState(() {
                                    final newCount = int.tryParse(value) ?? 0;
                                    ticketCounts[ticket.id] = newCount >= 0 ? newCount : 0;
                                    ticketControllers[ticket.id]!.text = '${ticketCounts[ticket.id]}';
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          )),
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
                            "Tổng cộng",
                            style: AppTextStyles.bold.copyWith(fontSize: 16),
                          ),
                          Text(
                            "${total.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")} VND",
                            style: AppTextStyles.bold.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isLoading || total <= 0
                            ? null
                            : () async {
                                setState(() => isLoading = true);
                                final eventViewModel = Provider.of<EventDetailViewModel>(
                                  context,
                                  listen: false,
                                );
                                final checkoutViewModel = Provider.of<CheckOutViewModel>(
                                  context,
                                  listen: false,
                                );
                                final toastContext = context;
                                final navigator = Navigator.of(context);

                                try {
                                  final orderItems = ticketCounts.entries
                                      .where((entry) => entry.value > 0)
                                      .map((entry) => {
                                            'ticket_id': entry.key,
                                            'quantity': entry.value,
                                          })
                                      .toList();

                                  final order = await eventViewModel.buyTicket(
                                    eventId: widget.eventId,
                                    orderItems: orderItems,
                                  );

                                  await checkoutViewModel.fetchOrderDetail(order.id);

                                  if (mounted) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      setState(() => isLoading = false);
                                      navigator.pop();
                                      ToastCustom.show(
                                        context: toastContext,
                                        title: 'Thành công',
                                        description: 'Đặt vé thành công! Mã đơn hàng: ${order.orderNo}',
                                        type: ToastificationType.success,
                                      );
                                      context.pushNamed('checkout', pathParameters: {'orderId': order.id});
                                    });
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      setState(() => isLoading = false);
                                      ToastCustom.show(
                                        context: toastContext,
                                        title: 'Lỗi',
                                        description: 'Lỗi: ${e.toString()}',
                                        type: ToastificationType.error,
                                      );
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          backgroundColor: const Color(0xFFEC0303),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: isLoading
                            ? const SpinKitFadingCircle(
                                color: Colors.white,
                                size: 24.0,
                              )
                            : Text(
                                "Mua vé",
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
      },
    );
  }

  Widget buildTicketOption(
    String title,
    String subtitle,
    int price,
    int count,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
    ValueChanged<String> onCountChanged,
  ) {
    final parts = subtitle.split('\n');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 84,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 39,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.medium.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7DCDC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            color: const Color(0xFF9B9B9B),
                            onPressed: onDecrement,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        Container(
                          width: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextField(
                            controller: TextEditingController(text: '$count'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.medium.copyWith(fontSize: 14),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                              isDense: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.black, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.linkBlue, width: 0.5),
                              ),
                            ),
                            onSubmitted: onCountChanged,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2176AE),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 18),
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
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black12,
          ),
          Container(
            height: 42,
            padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts[0],
                  style: AppTextStyles.medium.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}