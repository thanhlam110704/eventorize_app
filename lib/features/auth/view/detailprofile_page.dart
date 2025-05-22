import 'package:eventorize_app/common/widgets/labeled_input.dart';
import 'package:flutter/material.dart';
import 'package:eventorize_app/core/configs/theme/text_styles.dart';
import 'package:eventorize_app/core/configs/theme/colors.dart';
import 'package:eventorize_app/common/widgets/custom_field_input.dart';

class DetailprofilePage extends StatefulWidget {
  const DetailprofilePage({super.key});

  @override
  DetailprofilePageState createState() => DetailprofilePageState();
}

class DetailprofilePageState extends State<DetailprofilePage> {
  static const smallScreenThreshold = 640.0;
  static const maxContentWidth = 600.0;
  static const buttonHeight = 50.0;
  
  final fullnameController = TextEditingController(text: "Lâm Tuấn Thành");
  final emailController = TextEditingController(text: "ltthanh1107@gmail.com");
  final phoneController = TextEditingController(text: "123456789");
  final formKey = GlobalKey<FormState>();
  final fullnameInputKey = GlobalKey<CustomFieldInputState>();
  final phoneInputKey = GlobalKey<CustomFieldInputState>();
  
  String selectedCity = "HCM City";
  String selectedDistrict = "District 6";
  String selectedWard = "Ward 1";

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= smallScreenThreshold;

    return Scaffold(
      backgroundColor: AppColors.background,
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
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 40 : 80,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeaderRow(),
                const SizedBox(height: 16),
                buildAvatar(),
                const SizedBox(height: 24),
                buildSectionTitle(),
                const SizedBox(height: 16),
                buildFullnameField(),
                const SizedBox(height: 16),
                buildEmailField(),
                const SizedBox(height: 16),
                buildPhoneField(),
                const SizedBox(height: 16),
                buildCityDropdown(),
                const SizedBox(height: 16),
                buildDistrictDropdown(),
                const SizedBox(height: 16),
                buildWardDropdown(),
                const SizedBox(height: 32),
                buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 45), 
            child: Center(
              child: Text(
                "Detail info",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAvatar() {
    return Center(
      child: Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 54, 
            backgroundColor: Colors.black,
            child: Text(
              "LT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Upload
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
            ),
            child: Text(
              "Upload your image",
              style: AppTextStyles.text.copyWith(
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black,
                decorationThickness: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      )
    );
  }

  Widget buildSectionTitle() {
    return const Text("Personal information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget buildFullnameField() {
    return LabeledInput(
      label: "Fullname",
      child: TextFormField(
        controller: fullnameController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
        validator: (value) => value!.isEmpty ? "Please enter fullname" : null,
      ),
    );
  }

  Widget buildEmailField() {
    return LabeledInput(
      label: "Email address",
      child: TextFormField(
        initialValue: "ltthanh1107@gmail.com",
        enabled: false,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
      ),
    );
  }

  Widget buildPhoneField() {
    return LabeledInput(
      label: "Phone number",
      child: TextFormField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
        validator: (value) => value!.isEmpty ? "Please enter phone number" : null,
      ),
    );
  }

  Widget buildCityDropdown() {
    return LabeledInput(
      label: "City",
      child: DropdownButtonFormField<String>(
        value: selectedCity,
        items: ["HCM City", "Hanoi", "Da Nang"].map((city) {
         return DropdownMenuItem(value: city, child: Text(city));
        }).toList(),
        onChanged: (value) => setState(() => selectedCity = value!),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
      ),
    );
  }

  Widget buildDistrictDropdown() {
    return LabeledInput(
      label: "District",
      child: DropdownButtonFormField<String>(
        value: selectedDistrict,
        items: ["District 1", "District 6", "District 9"].map((district) {
          return DropdownMenuItem(value: district, child: Text(district));
        }).toList(),
        onChanged: (value) => setState(() => selectedDistrict = value!),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
      ),
    );
  }

  Widget buildWardDropdown() {
    return LabeledInput(
      label: "Ward",
      child: DropdownButtonFormField<String>(
        value: selectedWard,
        items: ["Ward 1", "Ward 5", "Ward 10"].map((ward) {
          return DropdownMenuItem(value: ward, child: Text(ward));
        }).toList(),
        onChanged: (value) => setState(() => selectedWard = value!),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
      ),
    );
  }

  Widget buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => handleUpdate(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Update detail info", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void handleUpdate(BuildContext context) {
    // Update
  }
}