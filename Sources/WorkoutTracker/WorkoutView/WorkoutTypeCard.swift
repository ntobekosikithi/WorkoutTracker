//
//  WorkoutTypeCard.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/16.
//

import SwiftUI
import Utilities

@available(iOS 14.0.0, *)
struct WorkoutTypeCard: View {
    let type: WorkoutType
    let isSelected: Bool
    let relevantGoalsCount: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.systemImage)
                    .font(.title2)
                
                Text(type.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)

                if relevantGoalsCount > 0 {
                    Text("\(relevantGoalsCount) goals")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
}
