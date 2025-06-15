//
//  WorkoutTypeSelector.swift
//  WorkoutTracker
//
//  Created by Ntobeko Sikithi on 2025/06/15.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
public struct WorkoutTypeSelector: View {
    @Binding var selectedType: WorkoutType
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Workout Type")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        VStack {
                            Image(systemName: type.systemImage)
                                .font(.title2)
                            Text(type.rawValue)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedType == type ? Color.blue : Color(.systemGray5))
                        .foregroundColor(selectedType == type ? .white : .primary)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}
