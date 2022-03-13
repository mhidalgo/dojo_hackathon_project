import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:dojo_app/colors.dart';
import 'package:dojo_app/widgets/page_title.dart';

class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PageTitle(title: 'TERMS OF SERVICE'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Color(0xFF161B30),
            margin: EdgeInsets.all(0),
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('TITLE 1', style: Theme.of(context).textTheme.bodyText1),
                          SizedBox(height:8),
                          Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Purus auctor nisl, orci vitae. Suspendisse sit in egestas commodo, nunc vitae, vitae consequat, lectus. Id adipiscing rutrum vel augue arcu, nullam. Nisl, et blandit nisi, laoreet adipiscing purus nunc dolor arcu. Fringilla et auctor ultricies dolor vitae metus. Consequat odio tincidunt ac pellentesque euismod blandit euismod eros, diam. ',
                              style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height:16),
                          Text('TITLE 2', style: Theme.of(context).textTheme.bodyText1),
                          SizedBox(height:8),
                          Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Purus auctor nisl, orci vitae. Suspendisse sit in egestas commodo, nunc vitae, vitae consequat, lectus. Id adipiscing rutrum vel augue arcu, nullam. Nisl, et blandit nisi, laoreet adipiscing purus nunc dolor arcu. Fringilla et auctor ultricies dolor vitae metus. Consequat odio tincidunt ac pellentesque euismod blandit euismod eros, diam. ',
                              style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height:16),
                          Text('TITLE 3', style: Theme.of(context).textTheme.bodyText1),
                          SizedBox(height:8),
                          Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Purus auctor nisl, orci vitae. Suspendisse sit in egestas commodo, nunc vitae, vitae consequat, lectus. Id adipiscing rutrum vel augue arcu, nullam. Nisl, et blandit nisi, laoreet adipiscing purus nunc dolor arcu. Fringilla et auctor ultricies dolor vitae metus. Consequat odio tincidunt ac pellentesque euismod blandit euismod eros, diam. ',
                              style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height:16),
                          Text('TITLE 3', style: Theme.of(context).textTheme.bodyText1),
                          SizedBox(height:8),
                          Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Purus auctor nisl, orci vitae. Suspendisse sit in egestas commodo, nunc vitae, vitae consequat, lectus. Id adipiscing rutrum vel augue arcu, nullam. Nisl, et blandit nisi, laoreet adipiscing purus nunc dolor arcu. Fringilla et auctor ultricies dolor vitae metus. Consequat odio tincidunt ac pellentesque euismod blandit euismod eros, diam. ',
                              style: Theme.of(context).textTheme.bodyText2),
                          SizedBox(height:16),
                          Text('TITLE 3', style: Theme.of(context).textTheme.bodyText1),
                          SizedBox(height:8),
                          Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Purus auctor nisl, orci vitae. Suspendisse sit in egestas commodo, nunc vitae, vitae consequat, lectus. Id adipiscing rutrum vel augue arcu, nullam. Nisl, et blandit nisi, laoreet adipiscing purus nunc dolor arcu. Fringilla et auctor ultricies dolor vitae metus. Consequat odio tincidunt ac pellentesque euismod blandit euismod eros, diam. ',
                              style: Theme.of(context).textTheme.bodyText2),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // top module
  }
}
