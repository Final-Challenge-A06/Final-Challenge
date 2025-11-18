import SwiftUI
import PhotosUI

@MainActor
struct GoalModalStep1View: View {
    @ObservedObject var vm: GoalViewModel
    @ObservedObject var bottomItemsVM: BottomItemSelectionViewModel
    var onNext: () -> Void
    
    // Animation states
    @State private var robotOffset: CGFloat = 0
    @State private var robotRotation: Double = -10
    @State private var dialogOpacity: Double = 0
    @State private var dialogScale: Double = 0.8
    @State private var dialogOffset: CGFloat = 0
    @State private var dialogRotation: Double = 0
    @State private var formOffset: CGFloat = 50
    @State private var formOpacity: Double = 0
    @State private var buttonScale: Double = 1.0
    @State private var frameOffset: CGFloat = -50
    @State private var modalOffset: CGFloat = -150
    @State private var bottomShadowOpacity: Double = 0
    @State private var displayedText: String = ""
    
    private let fullDialogText = "What do you want to save for?\nAdd a name, price, and picture if you want!"
    
    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Image("frame_top")
                .offset(y: frameOffset)
            
            Image("modal_setgoal")
                .offset(y: modalOffset)
            
            Image("ss_before")
                .resizable()
                .frame(width: 246, height: 246)
                .offset(y: 370)
            
            Image("modal_bottom_shadow")
                .offset(x: -10, y: 270)
                .opacity(bottomShadowOpacity)
            
            BottomItemSelectionView(viewModel: bottomItemsVM)
                .offset(x: 50, y: 580)
            
            Image("robot")
                .resizable()
                .frame(width: 200, height: 250)
                .offset(x: -350, y: 250 + robotOffset)
                .rotationEffect(.degrees(robotRotation))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 10)
            
            Text(displayedText)
            .font(.custom("audiowide", size: 16))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: 250, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                Rectangle()
                    .fill(Color.darkBlue)
            )
            .offset(x: -170, y: 220 + dialogOffset)
            .rotationEffect(.degrees(dialogRotation))
            .opacity(dialogOpacity)
            .scaleEffect(dialogScale)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Name your dream thing *")
                    .font(.custom("audiowide", size: 28))
                    .foregroundStyle(Color.white)
                
                TextField("", text: $vm.goalName)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.greenButton.opacity(100/255), in: RoundedRectangle(cornerRadius: 12))
                
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
                        vm.validateStep1()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(.greenButton.opacity(100/255), in: RoundedRectangle(cornerRadius: 12))
                
                if vm.priceValue > 0 && vm.priceValue < 50_000 {
                    Text("Minimum goal is Rp50.000")
                        .font(.custom("Audiowide", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                        .transition(.opacity.combined(with: .scale))
                }
                
                Text("How does it look?")
                    .font(.custom("audiowide", size: 28))
                    .foregroundStyle(Color.white)
                
                PhotosPicker(selection: $vm.selectedItem, matching: .images, photoLibrary: .shared()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.greenButton).opacity(100/255)
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
                                .transition(.scale.combined(with: .opacity))
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
                }
                .overlay(alignment: .topTrailing) {
                    if vm.selectedImage != nil {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                vm.selectedImage = nil
                            }
                            vm.selectedItem = nil
                            vm.validateStep1()
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red)
                                .shadow(radius: 3)
                        }
                        .padding(8)
                        .buttonStyle(.plain)
                    }
                }
                .onChange(of: vm.selectedItem, initial: false) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                vm.selectedImage = ui
                            }
                            vm.validateStep1()
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    Button {
                        onNext()
                    } label: {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.black)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 50)
                            .background(
                                vm.isStep1Valid
                                ? Color.yellow.opacity(0.7)
                                : Color.gray.opacity(0.4),
                                in: Capsule()
                            )
                            .scaleEffect(vm.isStep1Valid ? buttonScale : 1.0)
                            .shadow(color: vm.isStep1Valid ? .yellow.opacity(0.5) : .clear, radius: 10)
                    }
                    .disabled(!vm.isStep1Valid)
                    Spacer()
                }
                .padding(.top, 40)
                
            }
            .frame(width: 500)
            .offset(x: formOffset, y: -100)
            .opacity(formOpacity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Robot floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            robotOffset = -15
        }
        
        // Robot subtle rotation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            robotRotation = -5
        }
        
        // Frame slide in first
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            frameOffset = -30
        }
        
        // Shadow fade in FIRST (before modal)
        withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
            bottomShadowOpacity = 1
        }
        
        // Modal slide in AFTER shadow
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.7)) {
            modalOffset = -100
        }
        
        // Dialog bubble appear (after modal)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0)) {
            dialogOpacity = 1
            dialogScale = 1.0
        }
        
        // Start typewriter effect after dialog appears
        startTypewriterEffect(delay: 1.3)
        
        // Dialog floating animation (follows robot movement)
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            dialogOffset = -15
        }
        
        // Dialog subtle rotation (follows robot rotation)
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            dialogRotation = 2
        }
        
        // Form slide in from right (after modal appears)
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(1.2)) {
            formOffset = 0
            formOpacity = 1
        }
        
        // Button pulse animation when valid
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(2.0)) {
            buttonScale = 1.08
        }
    }
    
    private func startTypewriterEffect(delay: Double) {
        Task {
            try? await Task.sleep(for: .seconds(delay))
            
            for character in fullDialogText {
                displayedText.append(character)
                // Faster for spaces and punctuation, slower for letters
                let sleepDuration = character == " " || character == "\n" ? 0.02 : 0.04
                try? await Task.sleep(for: .seconds(sleepDuration))
            }
        }
    }
}

#Preview {
    GoalModalStep1View(
        vm: GoalViewModel(),
        bottomItemsVM: BottomItemSelectionViewModel(),
        onNext: {}
    )
}
