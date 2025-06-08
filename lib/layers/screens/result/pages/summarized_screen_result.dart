import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';


import 'package:voice_summary/layers/services/document_service.dart';



class SummarizedResultScreen extends StatelessWidget {
   SummarizedResultScreen({super.key, required this.summarizedText});
  final String summarizedText;
 

  final documentService = DocumentService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(documentService.extractHtmlTitle(summarizedText),style: Theme.of(context).textTheme.titleLarge?.copyWith(
          // color: Theme.of(context).colorScheme.onSurface.withAlpha(70),
        ),),
        actions: [
          // save
          IconButton(
              onPressed: () {
                documentService.generatePdfFromHtml(summarizedText);
              },
              icon: const Icon(Icons.save),
            ),
          IconButton(
              onPressed: () {
                SharePlus.instance.share(ShareParams(
                  text: documentService.stripHtmlTags(summarizedText),
                ));
              },
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(
                ClipboardData(text: documentService.stripHtmlTags(summarizedText)),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
              
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: HtmlWidget(summarizedText, enableCaching: true,textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            // color: Theme.of(context).colorScheme.onSurface.withAlpha(70),
          ),),
          // child: Text(summarizedText),
        ),
      ),
    );
  }



}
