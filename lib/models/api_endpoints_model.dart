class ApiEndpoints {
  final String upsertProfile;
  final String upsertCustomer;
  final String getProfile;
  final String installPackage;
  final String getPackages;
  final String getSchedule;
  final String getLocations;
  final String getAvailability;
  final String getConnectionRoles;
  final String getGenders;
  final String getCountryCodes;
  final String getServices;
  final String getMemberships;
  final String getNotifications;
  final String postCancellation;
  final String getAdminServices;
  final String getRecoveryFee;
  final String collectPayment;
  final String freezingRequest;
  final String displayDance;

  ApiEndpoints({
    required this.upsertProfile,
    required this.upsertCustomer,
    required this.getProfile,
    required this.installPackage,
    required this.getPackages,
    required this.getSchedule,
    required this.getLocations,
    required this.getAvailability,
    required this.getConnectionRoles,
    required this.getGenders,
    required this.getCountryCodes,
    required this.getServices,
    required this.getMemberships,
    required this.getNotifications,
    required this.postCancellation,
    required this.getAdminServices,
    required this.getRecoveryFee,
    required this.collectPayment,
    required this.freezingRequest,
    required this.displayDance,
  });

  factory ApiEndpoints.fromJson(Map<String, dynamic> json) {
    return ApiEndpoints(
      upsertProfile: json['upsert_profile'],
      upsertCustomer: json['upsert_customer'],
      getProfile: json['get_profile'],
      installPackage: json['install_package'],
      getPackages: json['get_packages'],
      getSchedule: json['get_schedule'],
      getLocations: json['get_locations'],
      getAvailability: json['get_availability'],
      getConnectionRoles: json['get_connection_roles'],
      getGenders: json['get_genders'],
      getCountryCodes: json['get_country_codes'],
      getServices: json['get_services'],
      getMemberships: json['get_memberships'],
      getNotifications: json['get_notifications'],
      postCancellation: json['post_cancellation'],
      getAdminServices: json['get_admin_services'],
      getRecoveryFee: json['get_recovery_fee'],
      collectPayment: json['collect_payment'],
      freezingRequest: json['post_freezing'],
      displayDance: json['display_dance'],
    );
  }
}
