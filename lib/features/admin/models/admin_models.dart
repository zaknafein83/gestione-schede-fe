/// Vista admin di un utente (include tier+roles, mai password).
class AdminUser {
  AdminUser({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.emailVerified,
    required this.tier,
    required this.premiumSince,
    required this.premiumSource,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String username;
  final String displayName;
  final bool emailVerified;
  final String tier;
  final DateTime? premiumSince;
  final String? premiumSource;
  final Set<String> roles;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isPremium => tier == 'PREMIUM';
  bool get isAdmin   => roles.contains('ADMIN');

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id:            json['id']            as String,
        email:         json['email']         as String,
        username:      json['username']      as String,
        displayName:   json['displayName']   as String,
        emailVerified: json['emailVerified'] as bool,
        tier:          (json['tier'] as String?) ?? 'FREE',
        premiumSince:  json['premiumSince']  == null
            ? null : DateTime.parse(json['premiumSince'] as String),
        premiumSource: json['premiumSource'] as String?,
        roles:         (json['roles'] as List<dynamic>?)
                ?.map((e) => e as String).toSet() ??
            <String>{},
        createdAt:     DateTime.parse(json['createdAt'] as String),
        updatedAt:     json['updatedAt']    == null
            ? null : DateTime.parse(json['updatedAt'] as String),
      );
}

/// Pagina di utenti dal backend.
class AdminUserPage {
  AdminUserPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<AdminUser> items;
  final int total;
  final int page;
  final int pageSize;

  factory AdminUserPage.fromJson(Map<String, dynamic> json) => AdminUserPage(
        items: ((json['items'] as List<dynamic>?) ?? const [])
            .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
            .toList(),
        total:    (json['total']    as num).toInt(),
        page:     (json['page']     as num).toInt(),
        pageSize: (json['pageSize'] as num).toInt(),
      );
}
