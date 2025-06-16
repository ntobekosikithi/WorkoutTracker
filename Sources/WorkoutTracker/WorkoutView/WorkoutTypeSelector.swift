//
//  WorkoutTypeSelector.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation
import SwiftUI
import Utilities
import GoalManager

@available(iOS 14.0, *)
public struct WorkoutTypeSelector: View {
    @Binding var selectedType: WorkoutType
    let goalManager: GoalManager
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Workout Type")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    WorkoutTypeCard(
                        type: type,
                        isSelected: selectedType == type,
                        relevantGoalsCount: goalManager.getRelevantGoals(for: type).count
                    ) {
                        selectedType = type
                    }
                }
            }
        }
    }
}
