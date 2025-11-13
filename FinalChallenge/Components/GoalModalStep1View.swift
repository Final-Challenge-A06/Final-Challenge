import SwiftUI
import PhotosUI

@MainActor
struct GoalModalStep1View: View {
    @ObservedObject var vm: GoalViewModel
    @ObservedObject var bottomItemsVM: BottomItemSelectionViewModel
    var onNext: () -> Void

    @State private var navigateToGoal = false

    var body: some View {
        ZStack {
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Image("frame_top")
                .offset(y: -30)
            
            Image("modal_setgoal")
                .offset(y: -100)
            
            Image("ss_before")
                .resizable()
                .frame(width: 246, height: 246)
                .offset(y: 370)
            
            Image("modal_bottom_shadow")
                .offset(x: -10, y: 270)
            
            BottomItemSelectionView(viewModel: bottomItemsVM)
                .offset(x: 50, y: 580)
            
            Image("robot")
                .resizable()
                .frame(width: 200, height: 250)
                .offset(x: -350, y: 250)
                .rotationEffect(.degrees(-10))
            
            Text("""
                 What do you want to save for?
                 Add a name, price, and picture if you want!
                 """)
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
                .offset(x: -170, y: 220)

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
                        if filtered != newValue { vm.priceText = filtered }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.greenButton, in: RoundedRectangle(cornerRadius: 12))

                Text("How does it look?")
                    .font(.custom("audiowide", size: 28))
                    .foregroundStyle(Color.white)

                PhotosPicker(selection: $vm.selectedItem, matching: .images, photoLibrary: .shared()) {
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
                                Image(systemName: "photo.on.rectangle").foregroundColor(.white)
                                Text("Select photos to upload")
                                    .font(.custom("audiowide", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .onChange(of: vm.selectedItem, initial: false) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let ui = UIImage(data: data) {
                            vm.selectedImage = ui
                            vm.validateStep1()
                        }
                    }
                }
                
                Text("How much does it cost?").font(.custom("audiowide", size: 28))
                
                TextField("e.g., 180000", text: $vm.priceText)
                    .keyboardType(.numberPad)
                    .onChange(of: vm.priceText) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            vm.priceText = filtered
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                
                if !(vm.priceText.isEmpty), (Int(vm.priceText) ?? 0) < 50_000 {
                    Text("Minimum goal is Rp50,000")
                        .font(.custom("Audiowide", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                        .transition(.opacity)
                }
                
                HStack () {
                    Spacer()
                    NavigationLink {
                        GoalModalStep2View(
                            vm: vm,
                            onDone: {
                                // Step 2 selesai -> arahkan ke GoalView
                                navigateToGoal = true
                            },
                            onBack: {
                                // kembali ke step 1 (pop otomatis oleh NavigationStack)
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                    } label: {
                        Image(systemName: "arrow.right")
                            .foregroundStyle(Color.black)
                            .padding(16)
                            .background(vm.isStep1Valid ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.4), in: Circle())
                            .padding(.vertical, 16)
                            .padding(.horizontal, 60)
                            .background(.yellowButton, in: Capsule())
                    }
                    .disabled(!vm.isStep1Valid)
                    Spacer()
                }
                .padding(.top, 40)
            }
            .frame(width: 500)
            .offset(y: -100)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationDestination(isPresented: $navigateToGoal) {
            GoalView()
                .navigationBarBackButtonHidden(true)
        }
}
}

#Preview {
    GoalModalStep1View(vm: GoalViewModel(), bottomItemsVM: BottomItemSelectionViewModel(), onNext: {})
}
