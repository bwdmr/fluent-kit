import NIOCore

/// A database that implements its operations natively with async/await.
///
/// Conforming to this protocol is opt-in. Drivers that conform get their
/// EventLoopFuture requirements auto-satisfied via bridging, so they never
/// need to touch EventLoopFuture themselves.
///
/// Existing drivers that conform to `Database` directly are unaffected.
public protocol AsyncDatabase: Database {
    
    func execute(
        query: DatabaseQuery,
        onOutput: @escaping @Sendable (any DatabaseOutput) -> ()
    ) async throws
    
    func execute(schema: DatabaseSchema) async throws
    func execute(enum: DatabaseEnum) async throws
    
    func transaction<T: Sendable>(
        _ closure: @escaping @Sendable (any Database) async throws -> T
    ) async throws -> T
    
    func withConnection<T: Sendable>(
        _ closure: @escaping @Sendable (any Database) async throws -> T
    ) async throws -> T
}


extension AsyncDatabase {

    // Bridge: async execute → ELF execute
    public func execute(
        query: DatabaseQuery,
        onOutput: @escaping @Sendable (any DatabaseOutput) -> ()
    ) -> EventLoopFuture<Void> {
        self.context.eventLoop.makeFutureWithTask {
            try await self.execute(query: query, onOutput: onOutput)
        }
    }

    public func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        self.context.eventLoop.makeFutureWithTask {
            try await self.execute(schema: schema)
        }
    }

    public func execute(enum e: DatabaseEnum) -> EventLoopFuture<Void> {
        self.context.eventLoop.makeFutureWithTask {
            try await self.execute(enum: e)
        }
    }

    public func transaction<T: Sendable>(
        _ closure: @escaping @Sendable (any Database) -> EventLoopFuture<T>
    ) -> EventLoopFuture<T> {
        self.context.eventLoop.makeFutureWithTask {
            try await self.transaction { db in
                try await closure(db).get()
            }
        }
    }

    public func withConnection<T: Sendable>(
        _ closure: @escaping @Sendable (any Database) -> EventLoopFuture<T>
    ) -> EventLoopFuture<T> {
        self.context.eventLoop.makeFutureWithTask {
            try await self.withConnection { db in
                try await closure(db).get()
            }
        }
    }
}

/// A driver that produces an AsyncDatabase.
/// Conforms to DatabaseDriver, so Databases doesn't need changes.
public protocol AsyncDatabaseDriver: DatabaseDriver {
    func makeDatabase(with context: DatabaseContext) -> any AsyncDatabase
}

extension AsyncDatabaseDriver {
    // Satisfies DatabaseDriver.makeDatabase automatically
    public func makeDatabase(with context: DatabaseContext) -> any Database {
        self.makeDatabase(with: context) as any AsyncDatabase
    }
}
