//
//  WorkoutService.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//


import Foundation
import Utilities
@available(iOS 13.0.0, *)
public protocol WorkoutService: Sendable {
    func saveSession(_ session: WorkoutSession) async throws
    func updateSession(_ session: WorkoutSession) async throws
    func getAllSessions() async throws -> [WorkoutSession]
    func getSession(by id: UUID) async throws -> WorkoutSession?
}

@available(iOS 13.0.0, *)
final actor WorkoutServiceImplementation: WorkoutService {
    private let dataStorage: DataStorage
    private let logger: Logger
    private let workoutSessionKey = "workout_session_key"
    init(
        dataStorage: DataStorage = DataStorageImplementation(),
        logger: Logger = Logger.shared
    ) {
        self.dataStorage = dataStorage
        self.logger = logger
    }
    
    func saveSession(_ session: WorkoutSession) async throws {
        let key = "workout_session_\(session.id.uuidString)"
        try dataStorage.save(session, forKey: key)
        logger.info("Saved workout session: \(session.id)")
        await saveSessions(session)
    }
    
    func saveSessions(_ session: WorkoutSession) async {
        if await !isSave(session) {
            do {
                var sessions = try await getAllSessions()
                sessions.append(session)
                try dataStorage.save(sessions, forKey: workoutSessionKey)
                logger.info("Saved workout session: \(session.id)")
            } catch {
                logger.info("Failed to save workout session: \(session.id)")
            }
        }
    }
    
    func updateSession(_ session: WorkoutSession) async throws {
        try await saveSession(session)
        logger.info("Updated workout session: \(session.id)")
    }
    
    func getAllSessions() async throws -> [WorkoutSession] {
        guard let data = try dataStorage.retrieve([WorkoutSession].self, forKey: workoutSessionKey) else {
            return []
        }
        return data
    }
    
    func getSession(by id: UUID) async throws -> WorkoutSession? {
        let key = "workout_session_\(id.uuidString)"
        guard let data = try dataStorage.retrieve(WorkoutSession.self, forKey: key) else {
            return nil
        }
        
        return data
    }
    
    func isSave(_ session: WorkoutSession) async -> Bool {
        do {
            let sessions = try await getAllSessions()
            return sessions.contains(session)
        } catch {
            return false
        }
    }
}
