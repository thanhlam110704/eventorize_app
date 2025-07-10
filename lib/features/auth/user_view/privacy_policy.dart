import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final ScrollController _scrollController = ScrollController();

  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());

  final List<String> _titles = [
    "1. Chúng tôi là ai",
    "2. Dịch vụ và Vai trò của Eventbrite",
    "3. Thông tin cá nhân được thu thập",
    "4. Cách chúng tôi sử dụng dữ liệu",
    "5. Cách chúng tôi chia sẻ và chuyển giao dữ liệu",
  ];

  final List<String> _contents = [
  // 1. Chúng tôi là ai
  "Eventbrite là nền tảng hỗ trợ tạo, khám phá và đăng ký sự kiện trực tuyến trên toàn cầu. "
      "Chúng tôi hoạt động thông qua các trang web, ứng dụng di động và dịch vụ kỹ thuật số khác để kết nối người tổ chức và người tham dự. "
      "Nếu bạn ở khu vực Châu Âu hoặc Anh, đại diện của chúng tôi là Eventbrite Operations (IE) và Eventbrite UK Limited.",

  // 2. Dịch vụ và vai trò của Eventbrite
  "Eventbrite cung cấp công cụ để người tổ chức tạo sự kiện và người dùng đăng ký tham gia. "
      "Chúng tôi không trực tiếp tổ chức hay kiểm soát sự kiện. "
      "Người tổ chức chịu trách nhiệm về nội dung, vé, quy trình đăng ký và tuân thủ pháp luật trong hoạt động sự kiện của họ.",

  // 3. Thông tin cá nhân được thu thập
  "Chúng tôi thu thập thông tin bạn cung cấp (họ tên, email, số điện thoại...) khi đăng ký, mua vé hoặc liên hệ hỗ trợ. "
      "Ngoài ra, chúng tôi còn tự động thu thập dữ liệu kỹ thuật như địa chỉ IP, trình duyệt, thiết bị, hành vi truy cập và cookie để phân tích trải nghiệm người dùng.",

  // 4. Cách chúng tôi sử dụng dữ liệu
  "Chúng tôi sử dụng thông tin cá nhân để cung cấp dịch vụ, cải thiện chức năng hệ thống, phân tích hành vi người dùng, bảo mật và hỗ trợ khách hàng. "
      "Chúng tôi cũng có thể sử dụng dữ liệu cho tiếp thị (email, quảng cáo) và cá nhân hóa trải nghiệm, khi được phép.",

  // 5. Cách chia sẻ và chuyển giao dữ liệu
  "Chúng tôi không bán dữ liệu cá nhân. Dữ liệu có thể được chia sẻ với đơn vị tổ chức sự kiện, đối tác thanh toán, nhà cung cấp dịch vụ (email, lưu trữ...) hoặc theo yêu cầu pháp lý. "
      "Trong trường hợp công ty sáp nhập hoặc bị mua lại, dữ liệu có thể được chuyển giao cho bên kế thừa.",
];

  void _scrollToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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
    final isShortScreen = screenSize.height < 600;

    return Scaffold(
      backgroundColor: AppColors.inputBackground,
      body: Column(
        children: [
          _buildTopBar(isSmallScreen, isShortScreen, context),
          Expanded(
            child: buildMainContainer(isSmallScreen, screenSize),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isSmallScreen, bool isShortScreen, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isShortScreen ? 24 : isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        0,
      ),
      child: TopNavBar(
        title: "Chính sách bảo mật",
        showBackButton: true,
        backgroundColor: AppColors.inputBackground,
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: AppColors.inputBackground,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 20 : 40,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cập nhật lần cuối: 3 tháng 7, 2024.",
                  style: AppTextStyles.semibold.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  "Nội dung trong bài viết",
                  style: AppTextStyles.semibold.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                ...List.generate(_titles.length, (index) {
                  return GestureDetector(
                    onTap: () => _scrollToSection(index),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0), 
                      child: Text(
                        _titles[index],
                        style: AppTextStyles.text.copyWith(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14),
                ...List.generate(_titles.length, (index) {
                  return Padding(
                    key: _sectionKeys[index],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titles[index],
                          style: AppTextStyles.semibold.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _contents[index],
                          style: AppTextStyles.text,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
