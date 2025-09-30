// lib/models/auth_models.dart

// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Register Request Model
class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? address;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
    };
  }
}

// User Model
class User {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['id_reseller'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

// Auth Response Model
class AuthResponse {
  final String token;
  final User user;
  final String? message;

  AuthResponse({
    required this.token,
    required this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Extract user data from the same level as access_token
    final userData = {
      'id': json['id'],
      'email': json['email'],
      'name': json['name'],
      'phone': json['phone'],
      'address': json['address'],
    };

    return AuthResponse(
      token: json['access_token'] ?? '',
      user: User.fromJson(userData),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'phone': user.phone,
      'address': user.address,
      'message': message,
    };
  }
}