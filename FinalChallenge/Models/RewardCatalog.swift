//
//  RewardCatalog.swift
//

import Foundation

enum RewardCatalog {
    private static let allEyeNames: [String] = [
        "mataKkBiru",
        "mataNgedipPink",
        "mataWinkHijau",
        "mataKkKuning",
        "mataNgedipUngu",
        "mataWinkOrange",
        "mataKkPutih",
        "mataNgedipHijau",
        "mataWinkPink",
        "mataKkOrange",
        "mataNgedipPutih",
        "mataWinkBiru",
        "mataKkPink",
        "mataNgedipKuning",
        "mataWinkUngu",
        "mataKkHijau",
        "mataNgedipOrange",
        "mataWinkPutih",
        "mataKkUngu",
        "mataNgedipBiru",
        "mataWinkKuning"
    ]
    
    private static func titleFromImage(_ name: String) -> String {
        let base = name.replacingOccurrences(of: "mata", with: "")
        let parts = base.splitBefore(capitals: true)
        
        guard parts.count >= 2 else { return "New Accessory" }
        
        let type = parts[0]
        let color = parts[1]
        
        let colorEng: String = [
            "Biru": "Blue",
            "Pink": "Pink",
            "Hijau": "Green",
            "Putih": "White",
            "Kuning": "Yellow",
            "Ungu": "Purple",
            "Orange": "Orange"
        ][String(color)] ?? String(color)
        
        let typeEng: String = [
            "Kk": "Left and Right Eyes",
            "Ngedip": "Blink Eyes",
            "Wink": "Wink Eyes"
        ][String(type)] ?? "Eyes"
        
        return "\(colorEng) \(typeEng)"
    }
    
    /// Versi lama: reward per goal (kalau masih mau dipakai somewhere)
    static func rewards(forTotalSteps totalSteps: Int) -> [RewardModel] {
        guard totalSteps > 0 else { return [] }
        
        var metas: [RewardModel] = []
        
        // First reward — tetap di step 1
        let firstName = allEyeNames[0]
        metas.append(
            RewardModel(
                id: "reward.step.1",
                step: 1,
                title: "Bright Blue Eyes",
                imageName: firstName
            )
        )
        
        guard totalSteps > 1 else { return metas }
        
        var imageIndex = 1
        for step in stride(from: 7, through: totalSteps, by: 7) {
            let name = allEyeNames[imageIndex % allEyeNames.count]
            imageIndex += 1
            
            metas.append(
                RewardModel(
                    id: "reward.step.\(step)",
                    step: step,
                    title: titleFromImage(name),
                    imageName: name
                )
            )
        }
        
        return metas
    }
    
    /// Dipakai untuk GLOBAL reward: index 0,1,2,... → mataKkBiru, mataNgedipPink, dst.
    static func appearanceForGlobalIndex(_ index: Int) -> (imageName: String, title: String) {
        let safe = max(index, 0)
        let name = allEyeNames[safe % allEyeNames.count]
        let title = titleFromImage(name)
        return (name, title)
    }
}

extension String {
    func splitBefore(capitals: Bool) -> [String] {
        var parts: [String] = []
        var current = ""
        
        for char in self {
            if char.isUppercase && !current.isEmpty {
                parts.append(current)
                current = ""
            }
            current.append(char)
        }
        if !current.isEmpty { parts.append(current) }
        return parts
    }
}
