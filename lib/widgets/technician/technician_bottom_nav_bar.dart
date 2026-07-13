import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class TechnicianBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const TechnicianBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index, String route) {
    if (index == currentIndex) return;
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            _navigate(context, index, AppRoutes.technicianServiceRequests);
            break;
          case 1:
            _navigate(context, index, AppRoutes.technicianPartyList);
            break;
          case 2:
            _navigate(context, index, AppRoutes.technicianProfile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_rounded),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.upload_file_rounded),
          label: 'Documents',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
