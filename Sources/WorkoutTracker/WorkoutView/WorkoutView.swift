//
//  WorkoutView.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/13.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
public struct WorkoutView: View {
    @StateObject private var workoutTracker = WorkoutTracker()
    @State private var selectedWorkoutType: WorkoutType = .running
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Current Session Card
                if let session = workoutTracker.currentSession {
                    WorkoutSessionCard(
                        session: session,
                        elapsedTime: workoutTracker.formattedElapsedTime,
                        isTracking: workoutTracker.isTracking
                    )
                } else {
                    WorkoutTypeSelector(selectedType: $selectedWorkoutType)
                }
                
                // Control Buttons
                WorkoutControls(
                    workoutTracker: workoutTracker,
                    selectedType: selectedWorkoutType,
                    onError: { message in
                        alertMessage = message
                        showingAlert = true
                    }
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Workout")
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}
