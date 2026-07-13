import 'package:flutter/material.dart';

class ServiceRequestStatusHelper {
  static Color color(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
      case 'RESOLVED':
      case 'CLOSED_BY_ADMIN':
        return Colors.green;
      case 'CLOSED':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'TECHNICIAN_ASSIGNED':
      case 'APPROVED':
        return Colors.teal;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  static String label(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
        return 'Verified';
      case 'CLOSED':
        return 'Closed';
      case 'CLOSED_BY_ADMIN':
        return 'Closed By Admin';
      case 'RESOLVED':
        return 'Resolved';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'TECHNICIAN_ASSIGNED':
        return 'Assigned';
      case 'APPROVED':
        return 'Approved';
      case 'PENDING':
      default:
        return 'Pending';
    }
  }

  static String technicianListLabel(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED':
        return 'Verified';
      case 'CLOSED':
        return 'Closed (Pending Admin Verification)';
      case 'CLOSED_BY_ADMIN':
        return 'Closed By Admin';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'TECHNICIAN_ASSIGNED':
      case 'APPROVED':
      case 'PENDING':
      default:
        return label(status);
    }
  }
}
