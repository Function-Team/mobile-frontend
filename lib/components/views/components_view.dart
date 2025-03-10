import 'package:flutter/material.dart';
import 'package:function_mobile/components/buttons/primary_button.dart';
import 'package:function_mobile/components/buttons/secondary_button.dart';
import 'package:function_mobile/components/buttons/outline_button.dart';
import 'package:function_mobile/components/inputs/auth_text_field.dart';
import 'package:function_mobile/components/inputs/search_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_mobile/modules/venue/components/venue_card.dart';

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
                onTap: () => {},
                venueName: 'Venue Name',
                location: 'Location',
                rating: 4.5,
                ratingCount: 4000,
                price: 100000,
                imageUrl:
                    'https://www.wework.com/ideas/wp-content/uploads/sites/4/2021/08/20201008-199WaterSt-2_fb.jpg?fit=1200%2C675',
                priceType: 'Rp',
              )
            ],
          ),
        )),
      ),
    );
  }
}
