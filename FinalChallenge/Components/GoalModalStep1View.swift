//
//  GoalModalStep1View.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI
import PhotosUI

struct GoalModalStep1View: View {
    @ObservedObject var vm: GoalViewModel
    var onNext: () -> Void
    var onClose: () -> Void
    
    private let goalOrange = Color(red: 0.91, green: 0.55, blue: 0.30)
    private let cardMint   = Color(red: 0.83, green: 0.95, blue: 0.90)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name your dream thing").font(.headline)
                
                TextField("Type here…", text: $vm.goalName)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.08)))
                
                PhotosPicker(
                    selection: $vm.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(height: 140)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.black.opacity(0.08), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                        
                        if let ui = vm.selectedImage {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.black.opacity(0.06))
                                )
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.black)
                                Text("Choose Photo")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                .onChange(of: vm.selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            vm.selectedImage = ui
                        }
                    }
                }
                
                Text("How much does it cost?").font(.headline)
                
                TextField("e.g., 180000", text: $vm.priceText)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.priceText) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            vm.priceText = filtered
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.08)))
                
                Button(action: { onNext() }) {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.black)
                        .background(goalOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 8)
                .disabled(!vm.isStep1Valid)
                
            }
            .padding(20)
            .background(cardMint, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.black.opacity(0.08)))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
            .frame(width: 560)
            
            Button { onClose() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(8)
                    .background(.white, in: Circle())
                    .shadow(radius: 2)
            }
            .padding(10)
        }
    }
}

#Preview {
    GoalModalStep1View(vm: GoalViewModel(), onNext: {}, onClose: {})
        .padding()
        .background(Color.gray.opacity(0.15))
}

