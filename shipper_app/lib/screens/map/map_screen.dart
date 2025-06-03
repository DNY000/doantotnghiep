//
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shipper_app/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shipper_app/ultils/const/enum.dart';
import 'package:shipper_app/viewmodels/order_viewmodel.dart';
import 'package:shipper_app/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  Position? currentPosition;
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  LatLng? _searchedLocation;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
      });

      try {
        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&countrycodes=vn&limit=5&addressdetails=1',
          ),
          headers: {'User-Agent': 'ShipperApp/1.0'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _searchResults =
                data.map((item) {
                  final address = item['address'] as Map<String, dynamic>;
                  String displayName = '';

                  if (address['road'] != null)
                    displayName += '${address['road']}, ';
                  if (address['suburb'] != null)
                    displayName += '${address['suburb']}, ';
                  if (address['city'] != null)
                    displayName += '${address['city']}, ';
                  if (address['state'] != null)
                    displayName += '${address['state']}, ';
                  if (address['country'] != null)
                    displayName += address['country'];

                  return {
                    'name':
                        displayName.isNotEmpty
                            ? displayName
                            : item['display_name'],
                    'lat': double.parse(item['lat']),
                    'lon': double.parse(item['lon']),
                    'address': address,
                  };
                }).toList();
          });

          // Nếu có kết quả, tự động chọn kết quả đầu tiên
          if (_searchResults.isNotEmpty) {
            // _selectLocation(_searchResults.first);
          }
        }
      } catch (e) {
        debugPrint('Error searching location: $e');
      } finally {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    final lat = location['lat'];
    final lon = location['lon'];
    setState(() {
      _searchedLocation = LatLng(lat, lon);
      _searchResults = [];
      _searchController.clear();
    });
    mapController.move(LatLng(lat, lon), 15.0);
  }

  Future<void> _initializeLocation() async {
    setState(() {
      isLoading = true;
    });

    // Yêu cầu quyền truy cập vị trí
    final hasPermission = await LocationService.requestLocationPermission(
      context,
    );

    if (hasPermission) {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          currentPosition = position;
          isLoading = false;
        });
        mapController.move(LatLng(position.latitude, position.longitude), 15.0);
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog();
      }
    } else {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog();
    }
  }

  Marker _buildOrderMarker(OrderModel order) {
    if (order.restaurantLocation == null) {
      return Marker(
        point: const LatLng(0, 0),
        width: 0,
        height: 0,
        child: const SizedBox.shrink(),
      );
    }

    return Marker(
      point: LatLng(
        order.restaurantLocation!.latitude,
        order.restaurantLocation!.longitude,
      ),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showOrderDetails(order),
        child: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white,

          child: Icon(Icons.location_on, color: Colors.red),
        ),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Delivery, Distance, Time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Delivery",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "0.5km",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Giao: 11:00",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Địa chỉ lấy hàng
                Row(
                  children: [
                    const Icon(Icons.store, color: Colors.blue, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.address, // Địa chỉ nhà hàng
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Cảnh báo món nhanh
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Có món nhanh",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Địa chỉ giao hàng
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.delivery?['address'] ?? "Địa chỉ giao hàng",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Số tiền thu
                Row(
                  children: [
                    const Text(
                      "Thu: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${order.totalAmount.toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Nút nhận đơn
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<OrderViewModel>().updateOrderStatus(
                        order.id,
                        OrderState.shipperAssigned,
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Nhận đơn",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 10),
                Text(
                  'Không thể lấy vị trí',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Vui lòng kiểm tra lại quyền truy cập vị trí và GPS của thiết bị.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Đóng',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _initializeLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Thử lại',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(21.0278, 105.8342),
              initialZoom: 20,
              minZoom: 10,
              maxZoom: 50,
              onMapReady: () {
                debugPrint('Map is ready');
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.shipper_app',
              ),
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: Colors.blue,
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  markerSize: Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              // Thêm marker cho vị trí tìm kiếm
              if (_searchedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _searchedLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers:
                    context
                        .watch<OrderViewModel>()
                        .orders
                        .where((order) => order.restaurantLocation != null)
                        .map((order) => _buildOrderMarker(order))
                        .toList(),
              ),
            ],
          ),
          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm địa điểm tại Việt Nam...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _searchedLocation = null;
                                  });
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _searchLocation,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _searchLocation(value).then((_) {
                          if (_searchResults.isNotEmpty) {
                            _selectLocation(_searchResults.first);
                          }
                        });
                      }
                    },
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(
                            result['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectLocation(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _initializeLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
