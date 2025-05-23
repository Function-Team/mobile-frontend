import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/images/network_image.dart';
import 'package:get/get.dart';

Widget buildBlog() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Blog',
        style: Get.theme.textTheme.headlineMedium,
      ),
      const SizedBox(height: 10),
      SizedBox(
          height: 220,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    margin: EdgeInsets.only(right: 16),
                    width: 200,
                    height: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: NetworkImageWithLoader(
                                imageUrl:
                                    'https://picsum.photos/seed/picsum/300/200'),
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: Text(
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            'Lorem Ipsum dolor sit amet',
                            style: Get.theme.textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ));
              })),
    ],
  );
}
