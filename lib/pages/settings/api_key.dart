import 'package:chatfusion/widgets/dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ApiKeySettingsPage extends StatefulWidget {
  final Function(bool)? onEnd;
  const ApiKeySettingsPage({super.key, this.onEnd});

  @override
  State<ApiKeySettingsPage> createState() => _ApiKeySettingsPageState();
}

class _ApiKeySettingsPageState extends State<ApiKeySettingsPage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final _apiKeyKey = TextFieldKey('apiKey');
  final TextEditingController _controller = TextEditingController();
  String? apiKey;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
    _storage.read(key: "apiKey").then((res) {
      if (res != null && mounted) {
        _controller.text = res;
      }
    });
  }

  void _updateUi() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_updateUi);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FormTableLayout(
            rows: [
              FormField<String>(
                key: _apiKeyKey,
                label: const Text('API Key'),
                validator: ValidationMode(
                  ConditionalValidator((value) {
                    return value!.startsWith("sk-");
                  }, message: '请输入正确的API Key'),
                  mode: {
                    FormValidationMode.changed,
                    FormValidationMode.submitted,
                  },
                ),
                child: TextField(
                  controller: _controller,
                  placeholder: const Text('请输入API Key'),
                  features: [
                    InputFeature.clear(),
                    InputFeature.passwordToggle(mode: PasswordPeekMode.hold),
                  ],
                ),
              ),
            ],
          ),
          const Gap(24),
          FormErrorBuilder(
            builder: (context, errors, child) {
              return PrimaryButton(
                size: ButtonSize.small,
                onPressed: errors.isEmpty ? () => context.submitForm() : null,
                child: const Text('保存'),
              );
            },
          ),
        ],
      ),
      onSubmit: (context, values) {
        _storage.write(key: "apiKey", value: values[_apiKeyKey]).then((res) {
          Navigator.pop(context);
          if (widget.onEnd != null) {
            widget.onEnd!(true);
          }
        }).catchError((err) {
          if (widget.onEnd != null) {
            widget.onEnd!(false);
          }
        });
      },
    );
  }
}

void showApiKeyDialog(BuildContext context, {Function(bool)? onEnd}) {
  showCusDialog(
    context,
    icon: Icon(BootstrapIcons.tools),
    title: Text("API KEY 配置"),
    child: ApiKeySettingsPage(
      onEnd: onEnd,
    ),
  );
}
