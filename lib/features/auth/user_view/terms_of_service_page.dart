import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_bar.dart';

class TOSPage extends StatefulWidget {
  const TOSPage({super.key});

  @override
  State<TOSPage> createState() => _TOSPageState();
}

class _TOSPageState extends State<TOSPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  final ScrollController _scrollController = ScrollController();

  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());

  final List<String> _titles = [
    "1. Chấp nhận Điều khoản",
    "2. Dịch vụ và Vai trò của Eventorize",
    "3. Quyền riêng tư & Thông tin người dùng",
    "4. Thời hạn và Chấm dứt",
    "5. Kiểm soát xuất khẩu & Quốc gia bị hạn chế",
  ];

  final List<String> _contents = [
    "Khi sử dụng dịch vụ của Eventorize, bạn đồng ý bị ràng buộc bởi các điều khoản, chính sách bảo mật và cookie của chúng tôi. "
        "Nếu bạn đại diện cho một tổ chức, bạn phải có thẩm quyền pháp lý để đồng ý thay mặt tổ chức đó. "
        "Tùy vào quốc gia bạn đang sinh sống, bạn sẽ ký hợp đồng với chi nhánh Eventorize tương ứng như tại Mỹ, Châu Âu, Úc, Canada hoặc các quốc gia khác.",

    "Eventorize cung cấp nền tảng để tạo, quảng bá và quản lý sự kiện. Chúng tôi không trực tiếp tổ chức hoặc sở hữu các sự kiện. "
        "Người tổ chức có toàn quyền kiểm soát và chịu trách nhiệm pháp lý về sự kiện, nội dung và phương thức thanh toán. "
        "Nếu sử dụng hệ thống thanh toán của Eventorize, chúng tôi chỉ đóng vai trò trung gian xử lý giao dịch.",

    "Chúng tôi cam kết bảo vệ dữ liệu cá nhân theo Chính sách bảo mật. "
        "Chúng tôi sử dụng cookie và công nghệ tương tự để theo dõi hành vi người dùng, giúp cải thiện trải nghiệm. "
        "Người tổ chức có nghĩa vụ tuân thủ luật về bảo mật và quyền riêng tư khi thu thập hoặc sử dụng thông tin từ người tham dự.",

    "Các điều khoản này có hiệu lực từ khi bạn bắt đầu sử dụng dịch vụ và sẽ tiếp tục cho đến khi bị chấm dứt. "
        "Chúng tôi có thể tạm ngưng hoặc chấm dứt quyền truy cập nếu bạn vi phạm điều khoản, sử dụng sai mục đích hoặc gây nguy hại cho cộng đồng. "
        "Bạn có thể xóa tài khoản để dừng sử dụng, nhưng nếu vẫn tiếp tục truy cập, điều khoản vẫn được áp dụng.",

    "Do tuân thủ luật kiểm soát xuất khẩu quốc tế, chúng tôi không thể cung cấp dịch vụ cho người hoặc tổ chức thuộc các quốc gia bị cấm vận "
        "như Cuba, Iran, Triều Tiên, Syria, Crimea... hoặc thuộc danh sách cấm của Mỹ, EU và các quốc gia khác. "
        "Bạn cam kết không sử dụng dịch vụ liên quan đến các đối tượng hoặc vùng lãnh thổ bị cấm.",
  ];

  final String _introNote = '''
Chào mừng bạn đến với Eventorize! Chúng tôi hiểu rằng người tạo và tham gia sự kiện đều mong muốn sự kiện diễn ra an toàn và suôn sẻ — và chúng tôi cũng vậy.

Vui lòng đọc kỹ Điều khoản Dịch vụ này vì chúng chứa thông tin quan trọng liên quan đến quyền, nghĩa vụ và trách nhiệm pháp lý của bạn.

Khi truy cập hoặc sử dụng dịch vụ của Eventorize, bạn đồng ý với các điều khoản được nêu ra (bao gồm cả Chính sách quyền riêng tư và các chính sách, điều khoản liên quan khác). Đây là một hợp đồng ràng buộc giữa bạn và chúng tôi. Nếu bạn không đồng ý, vui lòng không sử dụng dịch vụ.

Lưu ý quan trọng: Mục 9 của Điều khoản này có điều khoản ràng buộc trọng tài và từ bỏ quyền khởi kiện tập thể có thể ảnh hưởng đến quyền lợi pháp lý của bạn. Vui lòng đọc kỹ Mục 9.
''';

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
        title: "Điều khoản dịch vụ",
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
                const SizedBox(height: 24),
                Text(
                  _introNote,
                  style: AppTextStyles.text
                ),
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
