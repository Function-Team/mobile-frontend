import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/widgets/venue_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class VenueListPage extends StatelessWidget {
  const VenueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search venue',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Chip(label: Text('Mansion')),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
              ],
            ),
          )),
          Expanded(
            flex: 8,
            child: RefreshIndicator(
              onRefresh: () async {
                _buildShimmer();
              },
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return VenueCard(
                      venueName: 'Venue Name',
                      location: 'Location',
                      rating: 0,
                      ratingCount: 0,
                      price: 0,
                      imageUrl: '',
                      priceType: 'Rp',
                      onTap: () {},
                      roomType: 'Mansion',
                      capacityType: '100');
                },
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildShimmer() {
    return Skeletonizer(
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return VenueCard(
              venueName: 'Venue Name',
              location: 'Location',
              rating: 0,
              ratingCount: 0,
              price: 0,
              imageUrl: '',
              priceType: 'Rp',
              onTap: () {},
              roomType: 'Mansion',
              capacityType: '100');
        },
      ),
    );
  }
}
