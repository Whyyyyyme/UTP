import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Cari disini yuk!!!',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Explore item terbaru'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Explore item terbaru')),
                );
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.red),
              title: const Text('Lihat item terpopuler'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item terpopuler')),
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 24),

            const Text(
              'Trending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final tags = ['sepatu', 'hoodie', 'tas', 'cardigan', 'jaket'];
                  return Chip(
                    label: Text(tags[index]),
                    avatar: Icon(Icons.trending_up, size: 16),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Agar tidak scroll sendiri
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildCategoryCard(
                  'Wanita',
                  'https://via.placeholder.com/150?text=Skirt',
                ),
                _buildCategoryCard(
                  'Pria',
                  'https://via.placeholder.com/150?text=Jeans',
                ),
                _buildCategoryCard(
                  'Anak',
                  'https://via.placeholder.com/150?text=Toy',
                ),
                _buildCategoryCard(
                  'Hiburan',
                  'https://via.placeholder.com/150?text=Movie',
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Brands for you',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...[
                  'Adinda',
                  'Nikel',
                  'Polo Ralph Lauren',
                  'New Balance',
                  'Converse',
                  'The North Face',
                  'Stussy',
                  'MLB',
                  'Lacoste',
                  'Guess',
                  'Made in USA',
                  'Nike Air',
                  'Gildan',
                  'Giordano',
                  'Ellesse',
                  'Coach',
                ].map((brand) => Chip(label: Text(brand))),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black54,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
