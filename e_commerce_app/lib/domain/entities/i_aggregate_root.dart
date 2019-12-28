//identify domain entities that will act as an aggregate root

//The job of the aggregate root is to ensure that the
//aggregation remains in a consistent and valid state. The entity acting as the aggregate root will also
//have a corresponding repository to enable data persistence and retrieval.
abstract class IAggregateRoot {}
