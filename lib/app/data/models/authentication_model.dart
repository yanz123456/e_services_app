class LoginRequest {
  final String loginType, email, password, requestorId, type;
  final bool remember;
  const LoginRequest({
    this.loginType = 'valueEmail',
    this.email = '',
    this.password = '',
    this.requestorId = '',
    this.type = 'Student',
    this.remember = true,
  });
  Map<String, dynamic> toJson() => {
    'loginType': loginType,
    'email': email,
    'password': password,
    'requestorId': requestorId,
    'type': type,
    'remember': remember,
  };
}

class UserModel {
  final int id;
  final String name, email;
  const UserModel({required this.id, required this.name, required this.email});
  factory UserModel.fromJson(Map j) => UserModel(id: j['id'] ?? 0, name: j['name'] ?? '', email: j['email'] ?? '');
}

class LoginResponse {
  final String? token;
  final UserModel? user;
  final String? action;
  final Map<String, dynamic>? prefill;
  const LoginResponse({this.token, this.user, this.action, this.prefill});
  factory LoginResponse.fromJson(Map j) => LoginResponse(
    token: j['token'],
    user: j['user'] != null ? UserModel.fromJson(j['user']) : null,
    action: j['action'],
    prefill: (j['prefill'] as Map?)?.cast<String, dynamic>(),
  );
}
