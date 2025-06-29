import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';
import 'package:eventorize_app/features/auth/view_model/check_out_view_model.dart';
import 'package:eventorize_app/common/components/toast_custom.dart';
import 'package:eventorize_app/data/models/order.dart';

class CheckOutPage extends StatefulWidget {
  final String orderId;

  const CheckOutPage({super.key, required this.orderId});

  @override
  CheckOutPageState createState() => CheckOutPageState();
}

class CheckOutPageState extends State<CheckOutPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final ScrollController _scrollController = ScrollController();
  bool _showDivider = false;

  int _selectedMethod = 0;

  @override
  void initState() {
    super.initState();
    _showDivider = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CheckOutViewModel>(context, listen: false)
            .fetchOrderDetail(widget.orderId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TopNavBar(title: "Checkout", showBackButton: true),
            ),
            if (_showDivider)
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  color: AppColors.grey.withAlpha((0.5 * 255).toInt()),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withAlpha((0.6 * 255).toInt()),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Consumer<CheckOutViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (viewModel.errorMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        ToastCustom.show(
                          context: context,
                          title: viewModel.errorTitle ?? 'Lỗi',
                          description: viewModel.errorMessage!,
                          type: ToastificationType.error,
                        );
                        viewModel.clearError();
                      }
                    });
                    return Center(
                      child: Text(
                        'Lỗi: ${viewModel.errorMessage}',
                        style: AppTextStyles.text.copyWith(color: Colors.red),
                      ),
                    );
                  }
                  if (viewModel.order == null) {
                    return Center(
                      child: Text(
                        'Không tìm thấy đơn hàng',
                        style: AppTextStyles.text.copyWith(color: Colors.red),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: buildMainContainer(isSmallScreen, screenSize, viewModel.order!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize, Order order) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBillingInfo(order),
              const SizedBox(height: 24),
              buildOrderSummary(order),
              const SizedBox(height: 24),
              buildPaymentMethods(),
              const SizedBox(height: 24),
              buildPriceSection(order),
              const SizedBox(height: 24),
              buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBillingInfo(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing information', style: AppTextStyles.bold.copyWith(fontSize: 20)),
        const SizedBox(height: 12),
        buildLabeledInput('Fullname', order.userName ?? 'Không có tên', true),
        buildLabeledInput('Email address', order.userEmail ?? 'Không có email', true),
        buildLabeledInput('Phone number', order.userPhone ?? 'Không có số điện thoại', false),
      ],
    );
  }

  Widget buildLabeledInput(String label, String value, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.black),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: const TextStyle(
              color: Color(0xFF9B9B9B),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF9B9B9B)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderSummary(Order order) {
    final ticketPrice = order.amount.toString().replaceAllMapped(
        RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.");
    final fees = order.vatAmount.toString().replaceAllMapped(
        RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.");
    final total = order.totalAmount.toString().replaceAllMapped(
        RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.");
    final ticketCount = order.orderItems.fold<int>(
        0, (sum, item) => sum + item.quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order summary', style: AppTextStyles.bold.copyWith(fontSize: 20)),
        const SizedBox(height: 12),
        buildSummaryRow('${ticketCount}x Ticket price', '$ticketPrice VND'),
        buildSummaryRow('Fees (VAT ${order.taxRate * 100}%)', '$fees VND'),
        if (order.discountAmount != null && order.discountAmount! > 0)
          buildSummaryRow('Discount (${order.promotionCode ?? "N/A"})',
              '-${order.discountAmount.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")} VND'),
        const Divider(height: 24, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.bold.copyWith(fontSize: 16)),
              Text('$total VND', style: AppTextStyles.bold.copyWith(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.medium.copyWith(fontSize: 13)),
          Text(value, style: AppTextStyles.medium.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment method', style: AppTextStyles.bold.copyWith(fontSize: 20)),
        const SizedBox(height: 12),
        buildPaymentOption(0, 'Credit/Debit card', 'assets/icons/credit_logo.png'),
        const SizedBox(height: 8),
        buildPaymentOption(1, 'Paypal', 'assets/icons/paypal_logo.png'),
      ],
    );
  }

  Widget buildPaymentOption(int index, String label, String assetPath) {
    return InkWell(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Image.asset(
              assetPath,
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.text),
            ),
            Radio<int>(
              value: index,
              groupValue: _selectedMethod,
              activeColor: Colors.blue,
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPriceSection(Order order) {
    final total = order.totalAmount.toString().replaceAllMapped(
        RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Price',
              style: AppTextStyles.bold.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text('$total VND', style: AppTextStyles.medium.copyWith(fontSize: 13)),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEC0303),
            padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () async {
            final viewModel = Provider.of<CheckOutViewModel>(context, listen: false);
            final toastContext = context;
            final navigator = Navigator.of(context);
            try {
              await viewModel.acceptOrder(widget.orderId);
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ToastCustom.show(
                      context: toastContext,
                      title: 'Thành công',
                      description: 'Xác nhận đơn hàng thành công!',
                      type: ToastificationType.success,
                    );
                    navigator.pop();
                  }
                });
              }
            } catch (e) {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ToastCustom.show(
                      context: toastContext,
                      title: 'Lỗi',
                      description: 'Lỗi: ${e.toString()}',
                      type: ToastificationType.error,
                    );
                  }
                });
              }
            }
          },
          child: Text(
            'Place order',
            style: AppTextStyles.bold.copyWith(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 1),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: 'Powered by ',
            style: AppTextStyles.text.copyWith(fontSize: 13),
            children: [
              TextSpan(
                text: 'eventorize',
                style: AppTextStyles.bold.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}