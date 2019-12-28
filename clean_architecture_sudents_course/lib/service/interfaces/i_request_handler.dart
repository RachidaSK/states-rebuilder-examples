abstract class IRequestHandler<TRequest, TResponse> {
  TResponse handle(TRequest message);
}
