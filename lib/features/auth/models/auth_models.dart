/// Payload per POST /auth/register.
///
/// [acceptPrivacy] è la prova di consenso GDPR (art. 7(1)). Il backend
/// rifiuta la registrazione con 400 se è false o assente. Va settato a true
/// SOLO se l'utente ha realmente spuntato il checkbox in UI con i link a
/// /privacy e /terms.
class RegisterRequest {
  RegisterRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.displayName,
    required this.acceptPrivacy,
  });

  final String email;
  final String password;
  final String username;
  final String displayName;
  final bool   acceptPrivacy;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'username': username,
        'displayName': displayName,
        'acceptPrivacy': acceptPrivacy,
      };
}

/// Payload per PATCH /me — campi opzionali (null = non aggiornare).
class UpdateMeRequest {
  UpdateMeRequest({this.displayName, this.bio});
  final String? displayName;
  final String? bio;
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (displayName != null) m['displayName'] = displayName;
    if (bio         != null) m['bio']         = bio;
    return m;
  }
}

/// Payload per POST /me/change-password.
class ChangePasswordRequest {
  ChangePasswordRequest({required this.currentPassword, required this.newPassword});
  final String currentPassword;
  final String newPassword;
  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword':     newPassword,
      };
}

/// Payload per POST /auth/login.
class LoginRequest {
  LoginRequest({required this.email, required this.password});
  final String email;
  final String password;
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Risposta del login/refresh: contiene la coppia di token + (al login) l'utente.
class LoginResponse {
  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserDto user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken:  json['accessToken']  as String,
        refreshToken: json['refreshToken'] as String,
        user:         UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );
}

/// Vista pubblica utente restituita dal backend.
class UserDto {
  UserDto({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.emailVerified,
    required this.bio,
    required this.createdAt,
    required this.tier,
    required this.premiumSince,
    required this.premiumSource,
    required this.roles,
  });

  final String id;
  final String email;
  final String username;
  final String displayName;
  final bool emailVerified;
  final String? bio;
  final DateTime createdAt;
  final String tier;                // "FREE" | "PREMIUM"
  final DateTime? premiumSince;
  final String? premiumSource;      // "IAP_GOOGLE" | "IAP_APPLE" | "STRIPE" | "ADMIN_GRANT" | null
  final Set<String> roles;          // {} oppure {"ADMIN"}

  bool get isPremium => tier == 'PREMIUM';
  bool get isAdmin   => roles.contains('ADMIN');

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id:            json['id']            as String,
        email:         json['email']         as String,
        username:      json['username']      as String,
        displayName:   json['displayName']   as String,
        emailVerified: json['emailVerified'] as bool,
        bio:           json['bio']           as String?,
        createdAt:     DateTime.parse(json['createdAt'] as String),
        tier:          (json['tier'] as String?) ?? 'FREE',
        premiumSince:  json['premiumSince']  == null
            ? null : DateTime.parse(json['premiumSince'] as String),
        premiumSource: json['premiumSource'] as String?,
        roles:         (json['roles'] as List<dynamic>?)
                ?.map((e) => e as String).toSet() ??
            <String>{},
      );
}
