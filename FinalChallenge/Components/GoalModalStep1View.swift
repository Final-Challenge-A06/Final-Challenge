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
            Image("modal")
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Name your dream thing").font(.custom("audiowide", size: 28))
                
                TextField("Type here…", text: $vm.goalName)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.08)))
                
                Text("How does it look?").font(.custom("audiowide", size: 28))
                
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
                                    .foregroundColor(.black)
                                Text("Select photos to upload")
                                    .font(.custom("audiowide", size: 16))
                                    .foregroundColor(.black)
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
                
                Text("How much does it cost?").font(.custom("audiowide", size: 28))
                
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
                
                HStack () {
                    Spacer()
                    
                    Button(action: { onNext() }) {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.black)
                            .padding(16)
                            .background(.yellow.opacity(0.6), in: Circle())
                    }
                    .disabled(!vm.isStep1Valid)
                    
                    Spacer()
                }
                
            }
            .frame(width: 480)
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
        .background(Color.gray.opacity(0.15))
}
