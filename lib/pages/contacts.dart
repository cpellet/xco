import 'package:flutter/material.dart';

class ContactsPageView extends StatefulWidget {
  const ContactsPageView({Key? key}) : super(key: key);

  @override
  State<ContactsPageView> createState() => _ContactsPageViewState();
}

class _ContactsPageViewState extends State<ContactsPageView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Contacts page"),
    );
  }
}
