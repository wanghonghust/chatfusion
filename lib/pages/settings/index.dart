import 'package:chatfusion/notifier/theme.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

final Map<String, ColorScheme> colorSchemes = {
  'lightBlue': ColorSchemes.lightBlue(),
  'darkBlue': ColorSchemes.darkBlue(),
  'lightGray': ColorSchemes.lightGray(),
  'darkGray': ColorSchemes.darkGray(),
  'lightGreen': ColorSchemes.lightGreen(),
  'darkGreen': ColorSchemes.darkGreen(),
  'lightNeutral': ColorSchemes.lightNeutral(),
  'darkNeutral': ColorSchemes.darkNeutral(),
  'lightOrange': ColorSchemes.lightOrange(),
  'darkOrange': ColorSchemes.darkOrange(),
  'lightRed': ColorSchemes.lightRed(),
  'darkRed': ColorSchemes.darkRed(),
  'lightRose': ColorSchemes.lightRose(),
  'darkRose': ColorSchemes.darkRose(),
  'lightSlate': ColorSchemes.lightSlate(),
  'darkSlate': ColorSchemes.darkSlate(),
  'lightStone': ColorSchemes.lightStone(),
  'darkStone': ColorSchemes.darkStone(),
  'lightViolet': ColorSchemes.lightViolet(),
  'darkViolet': ColorSchemes.darkViolet(),
  'lightYellow': ColorSchemes.lightYellow(),
  'darkYellow': ColorSchemes.darkYellow(),
  'lightZinc': ColorSchemes.lightZinc(),
  'darkZinc': ColorSchemes.darkZinc(),
};

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeNotifier? themeNotifier;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: 0.6 * height,
      child: ListView(
        children: [
          Tabs(
              index: _index,
              onChanged: (index) {
                setState(() {
                  _index = index;
                });
                switch (index) {
                  case 0:
                    themeNotifier!.setTheme(ThemeMode.light);
                    break;
                  case 1:
                    themeNotifier!.setTheme(ThemeMode.dark);
                    break;
                  case 2:
                    themeNotifier!.setTheme(ThemeMode.system);
                }
              },
              children: [
                TabItem(child: Text('浅色')),
                TabItem(child: Text('深色')),
                TabItem(child: Text('跟随系统')),
              ]),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children:
                colorSchemes.keys.map(buildPremadeColorSchemeButton).toList(),
          ).p(),
        ],
      ),
    );
  }

  Widget buildPremadeColorSchemeButton(String name) {
    var scheme = colorSchemes[name]!;
    return scheme == themeNotifier!.currentTheme.colorScheme
        ? PrimaryButton(
            onPressed: () {
              themeNotifier!.setColorScheme(scheme);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.primaryForeground,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
                const Gap(8),
                Text(name),
              ],
            ),
          )
        : OutlineButton(
            onPressed: () {
              themeNotifier!.setColorScheme(scheme);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.primaryForeground,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
                const Gap(8),
                Text(name),
              ],
            ),
          );
  }
}
