import SwiftUI

struct SavingCardView: View {
    let title: String
    let current: Int
    let target: Int

    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 34)
//                .fill(.cardTeal)

            Image("background_saving")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Audiowide", size: 22))
                    .foregroundStyle(.white)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.24))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                        .frame(width: progressBarWidth, height: 20)
                        .animation(.easeInOut(duration: 0.35), value: progressBarWidth)
                }
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.8), lineWidth: 2)
                )

                HStack {
                    Spacer()
                    Text("\(rp(current))/\(currencyFormatter.string(from: NSNumber(value: target)) ?? "\(target)")")
                        .font(.custom("Audiowide", size: 16))
                        .foregroundStyle(.white)
                    Spacer()
                }
            
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
        }
        .frame(width: 400, height: 120, alignment: .leading)
    }

    private var progressBarWidth: CGFloat {
        let innerWidth: CGFloat = 400 - 44
        return innerWidth * progress
    }
    
    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return min(CGFloat(current) / CGFloat(target), 1)
    }

    private let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "."
        f.decimalSeparator = ","
        return f
    }()
    
    private func rp(_ value: Int) -> String {
        let body = currencyFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "Rp \(body)"
    }
}

#Preview {
    ZStack {
        HStack {
            SavingCardView(title: "Hirono Blindbox", current: 100000, target: 180_000)
            Spacer()
        }
        .padding(.leading, 24)
    }
}
