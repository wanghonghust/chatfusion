import 'package:chatfusion/widgets/markdown/element_builder.dart';
import 'package:chatfusion/widgets/markdown/flutter_markdown/src/style_sheet.dart';
import 'package:chatfusion/widgets/markdown/flutter_markdown/src/widget.dart';
import 'package:flutter/material.dart' show InkWell, MaterialTextSelectionControls;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

class MarkdownWidget extends StatefulWidget {
  final String? text;
  ScrollController? controller;
  MarkdownWidget({super.key, this.text, this.controller});
  @override
  State<MarkdownWidget> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownWidget>
    with AutomaticKeepAliveClientMixin {
  final MaterialTextSelectionControls materialTextControls =
      MaterialTextSelectionControls();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: materialTextControls,
        child: Markdown(
          controller: widget.controller,
          padding: EdgeInsets.all(5),
          data: widget.text ?? '',
          selectable: false,
          shrinkWrap: true,
          onTapLink: (text, href, title) async {
            Uri url = Uri.parse(href!);
            if (await launchUrl(url)) {}
          },
          imageBuilder: (uri, title, alt) {
            return InkWell(
              onTap: () {
                final imageProvider = Image.network(uri.toString()).image;
                showImageViewer(context, imageProvider,
                    onViewerDismissed: () {});
              },
              child: Image.network(uri.toString()),
            );
          },
          styleSheet: MarkdownStyleSheet(
            horizontalRuleDecoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.border, width: 0.5)),
            codeblockDecoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            blockquoteDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.border,
                border: Border(
                    left: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 4)),
                borderRadius: const BorderRadius.all(Radius.circular(4))),
          ),
          styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
          builders: {
            'code': CodeElementBuilder(context: context)
          },
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
