
abstract class Failure {
  final String errMessage;
  const Failure({required this.errMessage});
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required String errMessage, this.statusCode})
      : super(errMessage: errMessage);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required String errMessage})
      : super(errMessage: errMessage);
}

class CacheFailure extends Failure {
  const CacheFailure({required String errMessage})
      : super(errMessage: errMessage);
}