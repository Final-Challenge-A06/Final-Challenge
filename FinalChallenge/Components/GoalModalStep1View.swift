//
//  GoalModalStep1View.swift
//  FinalChallenge
//
//  Created by Angel Aprilia Putri Lo on 30/10/25.
//

import SwiftUI
import PhotosUI

@MainActor
struct GoalModalStep1View: View {
    @ObservedObject var vm = GoalViewModel()
    var onNext: () -> Void
    var onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("modal_goal")
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Name your dream thing *")
                    .font(.custom("audiowide", size: 28))
                    .foregroundStyle(Color.white)
                
                TextField("", text: $vm.goalName)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.greenButton, in: RoundedRectangle(cornerRadius: 12))
                
                Text("How much does it cost? *")
                    .font(.custom("audiowide", size: 28))
                    .foregroundStyle(Color.white)
                
                TextField("", text: $vm.priceText)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.priceText) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            vm.priceText = filtered
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.greenButton, in: RoundedRectangle(cornerRadius: 12))
                
                Text("How does it look?")
                    .font(.custom("audiowide", size: 28))
                    .foregroundStyle(Color.white)
                
                PhotosPicker(
                    selection: $vm.selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.greenButton)
                            .frame(height: 140)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.black.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
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
                                    .foregroundColor(.white)
                                Text("Select photos to upload")
                                    .font(.custom("audiowide", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                .onChange(of: vm.selectedItem, initial: false) { oldItem, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            await MainActor.run {
                                vm.selectedImage = ui
                            }
                        }
                    }
                }
                
                HStack () {
                    Spacer()
                    
                    Button(action: { onNext() }) {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.black)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 60)
                            .background(.yellowButton, in: Capsule())
                    }
                    .disabled(!vm.isStep1Valid)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .frame(width: 600)
        }
        .frame(width: 632, height: 700)
        .overlay(alignment: .topTrailing) {
            Button { onClose() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(8)
                    .background(.white, in: Circle())
                    .shadow(radius: 2)
            }
            .buttonStyle(.plain)
            .padding(10)
        }
    }
}

#Preview {
    GoalModalStep1View(onNext: {}, onClose: {})
        .padding()
//        .background(Color.gray.opacity(0.15))
}
