import 'package:flutter/material.dart';
import '../services/spotify_api.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _searchType = 'artist'; // 'artist' or 'album'

  final SpotifyApiService _spotifyApi = SpotifyApiService();

  void _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _spotifyApi.search(query, _searchType);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error fetching data')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search for artists or albums',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _searchType == 'artist' ? Colors.green : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchType = 'artist';
                      _searchResults = [];
                    });
                  },
                  child: const Text(
                    'Artists',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _searchType == 'album' ? Colors.green : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchType = 'album';
                      _searchResults = [];
                    });
                  },
                  child: const Text(
                    'Albums',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _searchType == 'artist'
                        ? _buildArtistList()
                        : _buildAlbumGrid(),
                  ),
          ],
        ),
      ),
    );
  }

  // Widget to build Artist List
  Widget _buildArtistList() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final artist = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: artist['images'] != null && artist['images'].isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(artist['images'][0]['url']),
                    radius: 30,
                  )
                : const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
            title: Text(
              artist['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Followers: ${artist['followers']['total'] ?? 0}',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Handle artist item click if needed
            },
          ),
        );
      },
    );
  }

  // Widget to build Album Grid
  Widget _buildAlbumGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        childAspectRatio: 2 / 3, // Adjust height-to-width ratio
        crossAxisSpacing: 16.0, // Spacing between columns
        mainAxisSpacing: 16.0, // Spacing between rows
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final album = _searchResults[index];
        final albumImage = album['images'] != null && album['images'].isNotEmpty
            ? album['images'][0]['url']
            : null;
        final albumName = album['name'] ?? 'Unknown Album';
        final artistName =
            album['artists'] != null && album['artists'].isNotEmpty
                ? album['artists'][0]['name']
                : 'Unknown Artist';
        final releaseYear = album['release_date'] != null
            ? album['release_date'].split('-')[0]
            : 'Unknown Year';

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: albumImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Image.network(
                          albumImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                        ),
                        child: Icon(Icons.album,
                            size: 50, color: Colors.grey[600]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      albumName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artistName,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      releaseYear,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
