//
//  WorkoutService.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//


import Foundation
import Utilities

@available(iOS 13.0, *)
public protocol WorkoutService: Sendable {
    func saveSession(_ session: WorkoutSession) async throws
    func updateSession(_ session: WorkoutSession) async throws
    func getAllSessions() async throws -> [WorkoutSession]
    func getSession(by id: UUID) async throws -> WorkoutSession?
}

@available(iOS 13.0, *)
final actor WorkoutServiceImplementation: WorkoutService {

    // MARK: - Properties

    private let dataStorage: DataStorage
    private let logger: Logger

    private let sessionListKey = "workout_session_key"

    // MARK: - Init

    init(
        dataStorage: DataStorage = DataStorageImplementation(),
        logger: Logger = LoggerImplementation()
    ) {
        self.dataStorage = dataStorage
        self.logger = logger
    }

    // MARK: - Public API

    func saveSession(_ session: WorkoutSession) async throws {
        try saveToIndividualStorage(session)
        await addToSessionListIfNeeded(session)
    }

    func updateSession(_ session: WorkoutSession) async throws {
        try await saveSession(session)
        logger.info("Updated workout session: \(session.id)")
    }

    func getAllSessions() async throws -> [WorkoutSession] {
        try dataStorage.retrieve([WorkoutSession].self, forKey: sessionListKey) ?? []
    }

    func getSession(by id: UUID) async throws -> WorkoutSession? {
        try dataStorage.retrieve(WorkoutSession.self, forKey: sessionKey(for: id))
    }

    // MARK: - Private Helpers

    private func saveToIndividualStorage(_ session: WorkoutSession) throws {
        try dataStorage.save(session, forKey: sessionKey(for: session.id))
        logger.info("Saved workout session: \(session.id)")
    }

    private func addToSessionListIfNeeded(_ session: WorkoutSession) async {
        guard await isNewSession(session) else { return }

        do {
            var sessions = try await getAllSessions()
            sessions.append(session)
            try dataStorage.save(sessions, forKey: sessionListKey)
            logger.info("Appended session to session list: \(session.id)")
        } catch {
            logger.error("Failed to append session to session list: \(session.id), error: \(error)")
        }
    }

    private func isNewSession(_ session: WorkoutSession) async -> Bool {
        do {
            let sessions = try await getAllSessions()
            return !sessions.contains { $0.id == session.id }
        } catch {
            logger.error("Failed to check session existence: \(session.id), error: \(error)")
            return false
        }
    }

    private func sessionKey(for id: UUID) -> String {
        "workout_session_\(id.uuidString)"
    }
}
