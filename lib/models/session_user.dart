class SessionUser {
  const SessionUser({required this.id, this.name, this.email});

  final String id;

  /// Nome vindo do provedor de login (ex.: conta Google), se houver.
  final String? name;
  final String? email;
}
