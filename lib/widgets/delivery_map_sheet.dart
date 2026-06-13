import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

Future<void> showDeliveryMapSheet(
  BuildContext context, {
  required Order order,
}) {
  final address = order.deliveryAddress;
  if (address == null || !address.hasCoordinates) {
    return Future.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeliveryMapSheet(address: address),
  );
}

class _DeliveryMapSheet extends StatelessWidget {
  final DeliveryAddress address;

  const _DeliveryMapSheet({required this.address});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(address.latitude!, address.longitude!);

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: AppTheme.charcoal2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(
          top: BorderSide(color: AppTheme.copper, width: 2),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.charcoal3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.cream,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.shortAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppTheme.copper,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mesamestre',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 54,
                          height: 54,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: AppTheme.copper,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.charcoal3.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.charcoal3, width: 1.2),
            ),
            child: Text(
              address.fullAddress,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
