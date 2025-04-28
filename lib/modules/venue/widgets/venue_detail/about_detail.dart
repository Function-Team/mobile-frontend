import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/widgets/venue_detail/facilities_section.dart';
import '../../../navigation/views/tab_nav.dart';

class AboutDetail extends StatelessWidget {
  final String venueName;
  final String venueDescription;

  const AboutDetail({
    super.key,
    required this.venueName,
    required this.venueDescription,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(venueName),
        titleTextStyle: theme.textTheme.displaySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        centerTitle: true,
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: TabNav(
          length: 3,
          tabs: [
            Tab(text: 'About'),
            Tab(text: 'Facilities'),
            Tab(text: 'Policy'),
          ],
          contents: [
            Container(
              margin: EdgeInsets.all(16),
              child: Column(children: [
                Text(venueDescription),
              ]),
            ),
            Container(
                margin: EdgeInsets.all(16),
                child: Column(
                  children: [FacilitiesSection()],
                )),
            Container(
              margin: EdgeInsets.all(16),
              child: Text(''),
            )
          ],
        ),
      ),
    );
  }
}
