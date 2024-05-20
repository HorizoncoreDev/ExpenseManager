import 'package:contacts_service/contacts_service.dart';
import 'package:expense_manager/utils/helper.dart';
import 'package:expense_manager/utils/languages/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  List<Contact> getContactList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Helper.getBackgroundColor(context),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Helper.getTextColor(context),
              )),
          title: Text(
            LocaleKeys.invite.tr,
            style: TextStyle(
                color: Helper.getTextColor(context),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Helper.getBackgroundColor(context),
          child: SingleChildScrollView(
              child: Container(
                  color: Helper.getBackgroundColor(context),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: getContactList.length,
                            itemBuilder: (BuildContext context, int index) {
                              Contact item = getContactList[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child:
                                      Text(item.displayName![0].toUpperCase()),
                                ),
                                title: Text(item.displayName.toString()),
                                subtitle:
                                    Text(item.phones![0].value.toString()),
                                trailing: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: InkWell(
                                      onTap: () {
                                        sendingSMS(
                                            '${LocaleKeys.hello.tr}, ${item.displayName}',
                                            '${item.phones![0].value}');
                                      },
                                      child: Text(
                                        LocaleKeys.invite.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                                // Add trailing icons for call, text, etc. here
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ))),
        ));
  }

  Future<void> fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      getContactList = contacts.toList();
    });
    contacts.forEach((contact) {
      print('Name: ${contact.displayName}');
      print('Phone: ${contact.phones![0].value}');
    });
  }

  @override
  void initState() {
    fetchContacts();
    super.initState();
  }

  void sendingSMS(String msg, String listRecipients) async {
    String encodedMessage = Uri.encodeComponent(msg);
    String encodedPhoneNumber = Uri.encodeComponent(listRecipients);

    // Construct the SMS URI
    String uri = 'sms:$encodedPhoneNumber?body=$encodedMessage';

    // Launch the SMS app
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
