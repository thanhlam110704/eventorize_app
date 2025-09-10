import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/components/top_nav_org_bar.dart';
import 'package:eventorize_app/common/components/custom_event_menu.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/features/auth/organization_view/edit_ticket_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  TicketListPageState createState() => TicketListPageState();
}

class TicketListPageState extends State<TicketListPage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0; 

  final List<Map<String, dynamic>> tickets = [
    {'title': 'Ticket A', 'sold': 0},
    {'title': 'Ticket B', 'sold': 30},
    {'title': 'Ticket C', 'sold': 0},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      appBar: TopNavOrgBar(
        leadingIcon: Icons.arrow_back_ios,
        title: 'Tickets',
        actionIcon: Icons.search,
        onActionPressed: () {
         // Submit logic
        },
      ),
      backgroundColor: AppColors.whiteBackground,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0,0,20,50),
        child: SizedBox(
          width: 70, 
          height: 70, 
          child: FloatingActionButton(
            onPressed: () {
              context.go('/createtickett');
            },
            backgroundColor: const Color(0xFF194185),
            elevation: 6,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32, 
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: buildMainContainer(isSmallScreen, screenSize),
        ),
      ),
    );
  }

  Widget buildMainContainer(bool isSmallScreen, Size screenSize) {
    return Container(
      width: screenSize.width,
      color: AppColors.whiteBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTicketList(),
        ],
      ),
    );
  }

  Widget buildTicketItem(int index, Map<String, dynamic> ticket) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '${index + 1}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket['title'],
                      style: AppTextStyles.semibold
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Free',
                          style: AppTextStyles.text.copyWith(color: Colors.red, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${ticket['sold']}/40 Sold',
                          style: AppTextStyles.text.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
              right: 0,
              top: 0,
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  onPressed: () {
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final position = box.localToGlobal(Offset.zero);
                    showEventMenu(context, position, () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditTicketPage()),
                    );
                    }, () {
                      // delete
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      const Divider(height: 1, thickness: 1, color: Colors.black12),
      ],
    );
  }

  Widget buildTicketList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        tickets.length,
        (index) => buildTicketItem(index, tickets[index]),
      ),
    ); 
  }

  void showEventMenu(BuildContext context, Offset position, VoidCallback onEdit, VoidCallback onDelete) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy + 40,
        left: position.dx - 80,
        child: Material(
          color: Colors.transparent,
          child: CustomEventMenu(onEdit: onEdit, onDelete: onDelete),
        ),
      ),
    );
    overlay.insert(entry);

    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (_) => GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const SizedBox.expand(),
        ),
      ).then((_) => entry.remove());
    });
  }
}

