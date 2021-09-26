import SwiftBlend2D
import ImagineUI

extension UIIntSize {
    @_transparent
    func scaled(by factor: UIVector, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        let width = Int((Double(width) * factor.x).rounded(roundingRule))
        let height = Int((Double(height) * factor.y).rounded(roundingRule))

        return .init(width: width, height: height)
    }

    @_transparent
    func scaled(by factor: BLPoint, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        scaled(by: factor.asUIVector, roundingRule: roundingRule)
    }

    @_transparent
    func scaled(by factor: Double, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        scaled(by: UIVector(repeating: factor), roundingRule: roundingRule)
    }
}
