import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key});

  @override
  EventDetailPageState createState() => EventDetailPageState();
}

class EventDetailPageState extends State<EventDetailPage>{
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildEventBanner(),
              buildMainContainer(isSmallScreen, screenSize),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black12,
          ),
          buildBottomBar(),
        ],
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
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
              buildEventTitleAndDate(),
              buildEventInformation(),
              const SizedBox(height: 24),
              buildEventDescription(),
              const SizedBox(height: 24),
              buildOrganizerSection(),
              const SizedBox(height: 24),
              buildRelatedToThisEvent(),
              const SizedBox(height: 24),
              buildEventList(),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget buildEventBanner() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/event1.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              iconSize: 24,
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEventTitleAndDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Friday, January 10, 6:00",
          style: AppTextStyles.text.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),  

        const SizedBox(height: 4),

        Text(
          "Mastering Vendor Development & The Service Provider Lifecycle",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget buildEventInformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Information about this event",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 1),
                child: const Icon(Icons.location_on, size: 24),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "53 Nguyen Co Thach, Thu Duc, Ho Chi Minh City",
                      style: AppTextStyles.text,
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Show map
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Show map",
                            style: AppTextStyles.text.copyWith(color: AppColors.linkBlue, fontSize: 14, fontWeight: FontWeight.w700),
                          ),

                          const SizedBox(width: 4),

                          Icon(
                            MdiIcons.chevronDown,
                            size: 14,
                            color: AppColors.linkBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.calendar_today, size: 24),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  "Friday, Jan 10, 6:00 - Monday, Jan 13, 8:00",
                  style: AppTextStyles.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: const Icon(Icons.attach_money, size: 24),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Refund policy", style: AppTextStyles.text),
                  const SizedBox(height: 6),
                  Text("No refunds", style: AppTextStyles.text.copyWith(fontSize: 14, color: Color(0xFF9B9B9B))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEventDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About this event",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "The event will gather migration agencies, immigration attorneys, global service providers, regional centers, project developers and investors from across the world.",
          style: AppTextStyles.text.copyWith(fontSize: 14, color: Color(0xFF9B9B9B)),
        ),

        const SizedBox(height: 9),

        GestureDetector(
          onTap: () {
            // to do
          },
          child: Text(
            "Read more",
            style: AppTextStyles.text.copyWith(
              color: AppColors.linkBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOrganizerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          "Organized by", 
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.w700
          )
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFEEE4E4),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/images/fpt.png"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("FPT Software", style: AppTextStyles.text.copyWith(fontWeight: FontWeight.bold, fontSize: 19)),
                    Text("22k Followers", style: AppTextStyles.text),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {}, // Follow action
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF0E32FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: 
                const Text(
                  "Follow",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w700
                  )
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  Widget buildRelatedToThisEvent() {
    final List<String> relatedTags = [
      "Offline Events",
      "Offline Events",
      "Offline Events",
      "Offline Events",
      "Offline Events",
      "Offline Events",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          "Related to this event",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          itemCount: relatedTags.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.5, 
          ),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEE4E4),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                relatedTags[index],
                textAlign: TextAlign.center,
                style: AppTextStyles.text.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildEventList() {
    return Column(
      children: List.generate(4, (index) => buildEventCard()).toList(),
    );
  }

  Widget buildEventCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                child: Image.asset(
                  'assets/icons/event.png',
                  height: 125,
                  width: 125,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mastering Vendor Development & The Service Provider...',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2), 
                      child: Icon(Icons.calendar_today, size: 14, color: Colors.black),
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        'Friday, Jan 10, 6:00 - Monday, Jan 13, 8:00',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ),
                 ],
                ),

                const SizedBox(height: 2),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2), 
                      child: Icon(Icons.location_on, size: 14, color: Colors.black),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '53 Nguyen Co Thach, Thu Duc, Ho Chi Minh City',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9B9B9B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.people, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    const Text(
                      '2.9k attendees',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9B9B9B),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite_border),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12), 
            child: Text(
            "Free",
            style: AppTextStyles.text.copyWith(fontSize: 18, fontWeight: FontWeight.w700)
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEC0303),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => const TicketDialog(),
              );
            },
            child: const Text(
              "Get tickets", 
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )
            ),
          ),
        ],
      ),
    );
  }
}

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
    int total = vipCount * vipPrice;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: UnconstrainedBox(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
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
                            const Text(
                              "Tickets",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const Spacer(),

                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black26),
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
                          () => setState(() =>
                              nonMemberCount = nonMemberCount > 0
                                  ? nonMemberCount - 1
                                  : 0),
                        ),

                        const SizedBox(height: 12),

                        buildTicketOption(
                          "VIP",
                          "150.000 VND",
                          vipPrice,
                          vipCount,
                          () => setState(() => vipCount++),
                          () => setState(() =>
                              vipCount = vipCount > 0 ? vipCount - 1 : 0),
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
                              style: AppTextStyles.text.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${total.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]}.")} VND",
                              style: AppTextStyles.text.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () {
                            // Checkout logic
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: const Color(0xFFEC0303),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)
                            ),
                          ),
                          child: const Text(
                            "Check out",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
          ),
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
                    style: AppTextStyles.text.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7DCDC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, size: 14),
                        color: Colors.black87,
                        onPressed: onDecrement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("$count", style: AppTextStyles.text.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2176AE),
                        borderRadius: BorderRadius.circular(6),
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
                )
              ],
            ),
          ),

          const Divider(height: 0, thickness: 1, color: Colors.black12),
          const SizedBox(height: 10), 
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parts[0],
                  style: AppTextStyles.text.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                ),  
                if (parts.length > 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    parts[1],
                    style: AppTextStyles.text.copyWith(fontSize: 13),
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
