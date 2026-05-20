import 'dart:math';

class VetClinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final bool isOpen;
  final String imageUrl;

  VetClinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.isOpen,
    required this.imageUrl,
  });
}

class VetDataService {
  /// Generates mock vet clinics based on a pseudo-random distance from the user.
  /// In a real app, this would call the Google Places API with the user's lat/lng.
  static Future<List<VetClinic>> getNearbyVets(
      double userLat, double userLng) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final random = Random();

    return [
      VetClinic(
        id: '1',
        name: 'City Pet Hospital',
        address: '124 Main Street, Colombo 03',
        phone: '+94 11 234 5678',
        rating: 4.8,
        reviewCount: 124,
        distanceKm: 1.2 + random.nextDouble(),
        isOpen: true,
        imageUrl:
            'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400&q=80',
      ),
      VetClinic(
        id: '2',
        name: 'Paws & Claws Clinic',
        address: '89 Marine Drive, Colombo 04',
        phone: '+94 11 876 5432',
        rating: 4.6,
        reviewCount: 89,
        distanceKm: 2.5 + random.nextDouble(),
        isOpen: true,
        imageUrl:
            'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400&q=80',
      ),
      VetClinic(
        id: '3',
        name: 'MediVet Emergency',
        address: '45 Galle Road, Colombo 06',
        phone: '+94 11 555 1234',
        rating: 4.9,
        reviewCount: 312,
        distanceKm: 3.8 + random.nextDouble(),
        isOpen: false,
        imageUrl:
            'https://images.unsplash.com/photo-1584820927508-eaafada87148?w=400&q=80',
      ),
      VetClinic(
        id: '4',
        name: 'Happy Tails Care',
        address: '12 Park Road, Nugegoda',
        phone: '+94 11 444 9876',
        rating: 4.3,
        reviewCount: 45,
        distanceKm: 5.1 + random.nextDouble(),
        isOpen: true,
        imageUrl:
            'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=400&q=80',
      ),
      VetClinic(
        id: '5',
        name: 'Royal Animal Center',
        address: '77 Kandy Road, Peliyagoda',
        phone: '+94 11 222 3333',
        rating: 4.7,
        reviewCount: 156,
        distanceKm: 7.4 + random.nextDouble(),
        isOpen: true,
        imageUrl:
            'https://images.unsplash.com/photo-1581888227599-779811939961?w=400&q=80',
      ),
    ]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }
}
