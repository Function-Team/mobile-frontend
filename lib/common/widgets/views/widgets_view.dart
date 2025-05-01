import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/buttons/secondary_button.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/inputs/auth_text_field.dart';
import 'package:function_mobile/common/widgets/inputs/search_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/widgets/venue_card.dart';

class ComponentsView extends StatelessWidget {
  const ComponentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              PrimaryButton(
                text: 'Logout',
                onPressed: () {},
              ),
              SizedBox(height: 18),
              SecondaryButton(text: 'Logout', onPressed: () {}),
              SizedBox(height: 18),
              OutlineButton(
                text: 'Logout',
                onPressed: () {},
                icon: FontAwesomeIcons.google,
                useFaIcon: true,
              ),
              SizedBox(height: 18),
              AuthTextField(
                  hintText: 'Enter your Email',
                  controller: TextEditingController()),
              SizedBox(height: 18),
              SearchTextField(
                hintText: 'Search',
                controller: TextEditingController(),
                icon: Icons.search,
              ),
              SizedBox(height: 18),
              VenueCard(
                onTap: () => {print('Card Clicked')},
                venue: VenueModel(),
              )
            ],
          ),
        )),
      ),
    );
  }
}
