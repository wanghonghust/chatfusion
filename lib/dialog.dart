import 'package:chatfusion/widgets/textarea/index.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as m;

class DialogPage extends StatefulWidget {
  DialogPage({super.key});

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CodeSnippet(
          code: '''
class DialogPage extends StatefulWidget {
  DialogPage({super.key});

  @override
  State<DialogPage> createState() => _DialogPageState();
}
''',
          mode: 'dart',
        ),
        PrimaryButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final FormController controller = FormController();
                return AlertDialog(
                  title: const Text('Edit profile'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          'Make changes to your profile here. Click save when you\'re done'),
                      const Gap(16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Form(
                          controller: controller,
                          child: const FormTableLayout(rows: [
                            FormField<String>(
                              key: FormKey(#name),
                              label: Text('Name'),
                              child: TextField(
                                initialValue: 'Thito Yalasatria Sunarya',
                              ),
                            ),
                            FormField<String>(
                              key: FormKey(#username),
                              label: Text('Username'),
                              child: TextField(
                                initialValue: '@sunaryathito',
                              ),
                            ),
                          ]),
                        ).withPadding(vertical: 16),
                      ),
                    ],
                  ),
                  actions: [
                    PrimaryButton(
                      child: const Text('Save changes'),
                      onPressed: () {
                        Navigator.of(context).pop(controller.values);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Edit Profile'),
        ),
        OutlineButton(
          onPressed: () {
            showPopover(
              alignment: Alignment.bottomLeft,
              context: context,
              builder: (context) {
                return const DropdownMenu(
                  children: [
                    MenuLabel(child: Text('My Account')),
                    MenuDivider(),
                    MenuButton(
                      child: Text('Profile'),
                    ),
                    MenuButton(
                      child: Text('Billing'),
                    ),
                    MenuButton(
                      child: Text('Settings'),
                    ),
                    MenuButton(
                      child: Text('Keyboard shortcuts'),
                    ),
                    MenuDivider(),
                    MenuButton(
                      child: Text('Team'),
                    ),
                    MenuButton(
                      subMenu: [
                        MenuButton(
                          child: Text('Email'),
                        ),
                        MenuButton(
                          child: Text('Message'),
                        ),
                        MenuDivider(),
                        MenuButton(
                          child: Text('More...'),
                        ),
                      ],
                      child: Text('Invite users'),
                    ),
                    MenuButton(
                      child: Text('New Team'),
                    ),
                    MenuDivider(),
                    MenuButton(
                      child: Text('GitHub'),
                    ),
                    MenuButton(
                      child: Text('Support'),
                    ),
                    MenuButton(
                      enabled: false,
                      child: Text('API'),
                    ),
                    MenuButton(
                      child: Text('Log out'),
                    ),
                  ],
                );
              },
            ).future.then((_) {
              print('Closed');
            });
          },
          child: const Text('Open'),
        ),
        TextField(
          style: TextStyle(fontSize: 16),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
        TextField(
          placeholder: Text('Enter your username'),
          initialValue: 'sunarya-thito',
          features: [
            InputFeature.revalidate(),
          ],
        ),
      ],
    );
  }
}
