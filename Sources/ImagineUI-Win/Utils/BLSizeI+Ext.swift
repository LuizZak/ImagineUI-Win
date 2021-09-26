import SwiftBlend2D
import ImagineUI

extension BLSizeI {
    @_transparent
    func scaled(by factor: BLPoint, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        let w = Int32((Double(w) * factor.x).rounded(roundingRule))
        let h = Int32((Double(h) * factor.y).rounded(roundingRule))

        return .init(w: w, h: h)
    }

    @_transparent
    func scaled(by factor: UIVector, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        scaled(by: factor.asBLPoint, roundingRule: roundingRule)
    }

    @_transparent
    func scaled(by factor: Double, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        scaled(by: UIVector(repeating: factor), roundingRule: roundingRule)
    }
}
