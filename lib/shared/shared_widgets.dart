import 'package:flutter/material.dart';

class SharedWidget {
  AppBar appBar(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }

  Center headerWithLogo() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo/lets-park-logo.png',
            width: 100,
          ),
          const Text(
            "7TH DEVS",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Text note(String note) {
    return Text(
      note,
      style: const TextStyle(
        fontSize: 23,
      ),
    );
  }

  TextFormField textFormField({
    required TextInputAction action,
    required TextEditingController controller,
    required String label,
    TextInputType textInputType = TextInputType.text,
    bool obscure = false,
    Icon? icon,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      textInputAction: action,
      controller: controller,
      obscureText: obscure,
      keyboardType: textInputType,
      decoration: InputDecoration(
        prefixIcon: icon,
        label: Text(label),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: validator,
    );
  }

  ElevatedButton button({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.lightBlue,
        fixedSize: const Size(140, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  AppBar appbarDrawer(
      {required String title, required VoidCallback onPressed}) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: onPressed,
      ),
      elevation: 2,
      bottom: PreferredSize(
        child: Container(
          color: Colors.white,
          height: 40,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        preferredSize: const Size.fromHeight(40),
      ),
    );
  }
}
