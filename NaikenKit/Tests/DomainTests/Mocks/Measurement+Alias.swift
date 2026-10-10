@testable import Domain

/// 毎回 `Domain.Measurement` と書かないのは、Foundation の `Measurement` と名前がぶつかり、モジュール名を付けないと曖昧になるため
typealias Measurement = Domain.Measurement
