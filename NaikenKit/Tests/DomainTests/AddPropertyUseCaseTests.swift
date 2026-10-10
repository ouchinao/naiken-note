import Foundation
import Testing
@testable import Domain

struct AddPropertyUseCaseTests {
    @Test("無料ユーザーが3件目を追加すると成功する")
    func freeUserCanAddThirdProperty() async throws {
        let repository = PropertyRepositoryMock(count: 2)
        let useCase = AddPropertyUseCase(
            repository: repository,
            entitlement: EntitlementProviderStub(current: .free)
        )

        let property = try await useCase.execute(name: "A棟201", visitedAt: Date())

        #expect(repository.saved.map(\.id) == [property.id])
    }

    @Test("無料ユーザーが4件目を追加すると limitReached で失敗する")
    func freeUserCannotAddFourthProperty() async {
        let useCase = AddPropertyUseCase(
            repository: PropertyRepositoryMock(count: 3),
            entitlement: EntitlementProviderStub(current: .free)
        )

        await #expect(throws: AddPropertyUseCase.Failure.limitReached(limit: 3)) {
            try await useCase.execute(name: "B棟101", visitedAt: Date())
        }
    }

    @Test("上限に達して失敗したときは保存しない")
    func doesNotSaveWhenLimitReached() async {
        let repository = PropertyRepositoryMock(count: 3)
        let useCase = AddPropertyUseCase(
            repository: repository,
            entitlement: EntitlementProviderStub(current: .free)
        )

        _ = try? await useCase.execute(name: "B棟101", visitedAt: Date())

        #expect(repository.saved.isEmpty)
    }

    @Test("解錠済みユーザーは件数に関係なく追加できる", arguments: [Entitlement.unlocked, .pro])
    func unlockedUserHasNoLimit(entitlement: Entitlement) async throws {
        let useCase = AddPropertyUseCase(
            repository: PropertyRepositoryMock(count: 100),
            entitlement: EntitlementProviderStub(current: entitlement)
        )

        _ = try await useCase.execute(name: "C棟301", visitedAt: Date())
    }

    @Test("無料ユーザーが上限に達していると追加前の確認で limitReached になる")
    func checkLimitThrowsAtLimit() async {
        let useCase = AddPropertyUseCase(
            repository: PropertyRepositoryMock(count: 3),
            entitlement: EntitlementProviderStub(current: .free)
        )

        await #expect(throws: AddPropertyUseCase.Failure.limitReached(limit: 3)) {
            try await useCase.checkLimit()
        }
    }

    @Test("入力した項目をすべて保存する")
    func savesAllFields() async throws {
        let repository = PropertyRepositoryMock()
        let useCase = AddPropertyUseCase(
            repository: repository,
            entitlement: EntitlementProviderStub(current: .free)
        )
        let property = Property(
            id: UUID(),
            name: "D棟102",
            rent: 85_000,
            layout: "1LDK",
            areaSquareMeters: 32.5,
            nearestStation: "三軒茶屋",
            walkMinutes: 7,
            visitedAt: Date(),
            memo: "南向き",
            createdAt: Date()
        )

        _ = try await useCase.execute(property)

        #expect(repository.saved == [property])
    }
}
