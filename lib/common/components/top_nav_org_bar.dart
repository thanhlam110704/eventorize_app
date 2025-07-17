import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:flutter/material.dart';

class TopNavOrgBar extends StatefulWidget implements PreferredSizeWidget {
  final IconData leadingIcon;
  final VoidCallback? onLeadingPressed;
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final ValueChanged<String>? onSearchChanged;

  const TopNavOrgBar({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.onLeadingPressed,
    this.actionIcon,
    this.onActionPressed,
    this.onSearchChanged,
  });

  @override
  TopNavOrgBarState createState() => TopNavOrgBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TopNavOrgBarState extends State<TopNavOrgBar> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        if (widget.onSearchChanged != null) {
          widget.onSearchChanged!('');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1E266D),
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(widget.leadingIcon, color: Colors.white),
              onPressed: widget.onLeadingPressed,
            ),
            Expanded(
              child: _isSearchActive
                  ? TextField(
                      controller: _searchController,
                      style: AppTextStyles.text.copyWith(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        hintStyle: AppTextStyles.text.copyWith(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: widget.onSearchChanged,
                      autofocus: true,
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.title,
                        style: AppTextStyles.bold.copyWith(fontSize: 25, color: Colors.white),
                      ),
                    ),
            ),
            if (widget.actionIcon != null)
              IconButton(
                icon: Icon(
                  _isSearchActive ? Icons.close : widget.actionIcon,
                  color: Colors.white,
                ),
                onPressed: () {
                  _toggleSearch();
                  if (!_isSearchActive && widget.onActionPressed != null) {
                    widget.onActionPressed!();
                  }
                },
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}