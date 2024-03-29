import SwiftBlend2D
import ImagineUI

extension UIRectangle {
    @_transparent
    func scaled(by factor: UIVector, roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        let x = (x * factor.x).rounded(roundingRule)
        let y = (y * factor.y).rounded(roundingRule)
        let width = (width * factor.x).rounded(roundingRule)
        let height = (height * factor.y).rounded(roundingRule)

        return .init(x: x, y: y, width: width, height: height)
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
