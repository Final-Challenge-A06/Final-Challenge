import SwiftUI

struct SavingInputModalView: View {
    var title: String = "Mau nabung berapa hari ini?"
    @Binding var amountText: String
    var onCancel: () -> Void
    var onSave: (Int) -> Void

    private let cardBackground = Color(red: 0.83, green: 0.95, blue: 0.90)
    private let actionColor = Color(red: 0.91, green: 0.55, blue: 0.30)

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title3.bold())

            TextField("e.g., 50000", text: $amountText)
                .keyboardType(.numberPad)
                .onChange(of: amountText) {
                    let v = amountText
                    let digits = v.filter(\.isNumber)
                    if digits != v { amountText = digits }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.black.opacity(0.08)))

            HStack(spacing: 12) {
                Button("Batal", action: onCancel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.white)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.black.opacity(0.1)))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)

                Button("Simpan") {
                    let value = Int(amountText) ?? 0
                    onSave(value)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.black)
                .background(actionColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .buttonStyle(.plain)
                .disabled((Int(amountText) ?? 0) <= 0)
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.black.opacity(0.08)))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
        .frame(width: 420)
    }
}

#Preview {
    @Previewable @State var txt = ""
    ZStack {
        Color.gray.opacity(0.15).ignoresSafeArea()
        SavingInputModalView(amountText: $txt, onCancel: {}, onSave: { _ in })
    }
}
