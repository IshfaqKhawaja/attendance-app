sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(Failure) err}) =>
      switch (this) { Ok(value: final v) => ok(v), Err(failure: final f) => err(f) };
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}

class Failure {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const Failure(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => 'Failure(message: ' + message + ', cause: ' + (cause?.toString() ?? 'null') + ')';
}
