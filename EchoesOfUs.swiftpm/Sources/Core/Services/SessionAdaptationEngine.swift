import Foundation

struct SessionAdaptationEngine: AdaptationEngine {
    func hintLevel(for mistakes: Int, elapsedSeconds: Int) -> Int {
        if mistakes == 0 && elapsedSeconds < 20 {
            return 0
        }
        if mistakes <= 1 && elapsedSeconds < 50 {
            return 1
        }
        if mistakes <= 3 && elapsedSeconds < 95 {
            return 2
        }
        return 3
    }

    func recommendedNextDifficulty(current: Int, streak: Int) -> Int {
        if streak >= 2 {
            return min(5, current + 1)
        }
        if streak == 0 {
            return max(1, current - 1)
        }
        return current
    }
}
