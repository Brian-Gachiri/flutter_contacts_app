import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Iterable<Contact>? _contacts;

  final List<String> entries = <String>[
    'Jonte wa Mashati',
    'Alibaba na mabazu 40',
    'Axe Black',
    'Lukas Graham',
    'Simon Petero',
    'Paulo na Sila',
    'Samson Kimathi',
    'My sugar my tea',
    'Yes Jesus loves me'
  ];
  final List<int> colorCodes = <int>[
    600,
    500,
    100,
    600,
    500,
    100,
    600,
    500,
    100
  ];

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();

      return permissionStatus[Permission.contacts] ??
          PermissionStatus.denied;
    } else {
      return permission;
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final PermissionStatus permissionStatus = await _getPermission();
      if (permissionStatus == PermissionStatus.granted) {
        final Iterable<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = contacts;
        });
      } else {

        Map<Permission, PermissionStatus> statuses = await [
          Permission.contacts,
        ].request();

        if(statuses[Permission.contacts] == PermissionStatus.granted){

          final Iterable<Contact> contacts = await ContactsService.getContacts();
          setState(() {
            _contacts = contacts;
          });

        }
        else{
          Fluttertoast.showToast(  
            msg: 'Permission to read contacts denied.',  
            toastLength: Toast.LENGTH_SHORT,  
            gravity: ToastGravity.CENTER,  
            timeInSecForIosWeb: 1,  
            backgroundColor: Colors.orange,  
            textColor: Colors.white  
        );  
        }
        
        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) => CupertinoAlertDialog(
        //           title: const Text('Permissions error'),
        //           content: const Text('Please enable contacts access '
        //               'permission in system settings'),
        //           actions: <Widget>[
        //             CupertinoDialogAction(
        //               child: const Text('OK'),
        //               onPressed: () => Navigator.of(context).pop(),
        //             )
        //           ],
        //         ));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Search for contacts',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              )),
          _contacts != null ?  Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact? contact = _contacts?.elementAt(index);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue[colorCodes[1]],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(contact?.displayName ?? 'Unknown'),
                    ), 
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          ) : const Center(child:  CircularProgressIndicator()),
        ],
      ),
    );
  }
}
