//
//  BatteryProgressModel.swift
//  SPPB
//
//  Created by Richard Pfannenstiel on 04.07.23.
//

import SwiftUI

final class BatteryProgressModel: ViewModel {
    
    static var lastTestsStatus: [Test]?
    
    // MARK: - Stored Properties
    
    @Published var showingBalanceTestsHighlighted = false
    @Published var showingIndividualBalanceTests = false
    @Published var showingIndividualBalanceTestsExpanded = false
    
    @Published var showingGaitTestsHighlighted = false
    @Published var showingIndividualGaitTests = false
    @Published var showingIndividualGaitTestsExpanded = false
    
    @Published var showingChairStandTestsHighlighted = false
    @Published var showingIndividualChairStandTests = false
    @Published var showingIndividualChairStandTestsExpanded = false
    
    @Published var animating = false
    @Published var animationFinished = false
    
    @Published var sideBySideFinished = false
    @Published var sideBySideBulletColor: Color = .white
    @Published var semiTandemFinished = false
    @Published var semiTandemBulletColor: Color = .white
    @Published var tandemFinished = false
    @Published var tandemBulletColor: Color = .white
    
    @Published var firstGaitFinished = false
    @Published var firstGaitBulletColor: Color = .white
    @Published var secondGaitFinished = false
    @Published var secondGaitBulletColor: Color = .white
    
    @Published var singleChairStandFinished = false
    @Published var singleChairStandBulletColor: Color = .white
    @Published var repeatedChairStandFinished = false
    @Published var repeatedChairStandBulletColor: Color = .white
    
    @Published var viewHeight: CGFloat = 0
    
    let battery: Battery
    
    // MARK: - Computed Properties
    
    var balanceTestFinished: Bool {
        sideBySideFinished && semiTandemFinished && tandemFinished
    }
    
    var gaitTestFinished: Bool {
        firstGaitFinished && secondGaitFinished
    }
    
    var chairStandTestFinished: Bool {
        singleChairStandFinished && repeatedChairStandFinished
    }
    
    var progressLineLength: CGFloat {
        let test = animating ? battery.nextTest : battery.lastTest
        
        guard let test = test else {
            return animating ? viewHeight : 0
        }
        if let balanceTest = test as? BalanceTest {
            if !showingBalanceTestsHighlighted {
                if showingGaitTestsHighlighted {
                    return 15
                } else {
                    return 0.25 * viewHeight
                }
            }
            if !showingIndividualBalanceTestsExpanded {
                return 0.4 * viewHeight
            }
            switch balanceTest.pose {
            case .side_by_side:
                return 0.4 * viewHeight - 75
            case .semi_tandem:
                return 0.4 * viewHeight
            case .tandem:
                return 0.4 * viewHeight + 75
            }
            
        }
        if let test = test as? GaitTest {
            if !showingGaitTestsHighlighted {
                if showingChairStandTestsHighlighted {
                    return viewHeight * 0.1
                } else {
                    return 0.5 * viewHeight
                }
            }
            if !showingIndividualGaitTestsExpanded {
                return 0.5 * viewHeight
            }
            if test.number == 1 {
                return 0.5 * viewHeight - 25
            } else {
                return 0.5 * viewHeight + 50
            }
        }
        if let chairStandTest = test as? ChairStandTest {
            if !showingChairStandTestsHighlighted {
                return 0.75 * viewHeight
            }
            if !showingIndividualChairStandTestsExpanded {
                return 0.6 * viewHeight
            }
            switch chairStandTest.testType {
            case .single:
                return 0.6 * viewHeight - 25
            case .repeated:
                return 0.6 * viewHeight + 50
            }
        }
        return 0
    }
    
    // MARK: - Initializer
    
    init(for battery: Battery) {
        self.battery = battery
    }
    
    convenience init(for tests: [Test]) {
        let battery = Battery(tests: tests)
        self.init(for: battery)
    }
    
    // MARK: - Functions
    
    func next() {
        // Update last battery static variable.
        BatteryProgressModel.lastTestsStatus = battery.tests
        battery.next()
    }
    
    func setHeight(height: CGFloat) {
        viewHeight = height
    }
    
    func setup() {
        // Set the progress view to the state before completing the last test.
        if battery.lastTest is BalanceTest {
            show(
                highlight: { [self] in
                    showingBalanceTestsHighlighted.toggle()
                }, individualize: { [self] in
                    showingIndividualBalanceTests.toggle()
                }, expand: { [self] in
                    showingIndividualBalanceTestsExpanded.toggle()
                })
        }
        if battery.lastTest is GaitTest {
            show(
                highlight: { [self] in
                    showingGaitTestsHighlighted.toggle()
                }, individualize: { [self] in
                    showingIndividualGaitTests.toggle()
                }, expand: { [self] in
                    showingIndividualGaitTestsExpanded.toggle()
                })
        }
        if battery.lastTest is ChairStandTest {
            show(
                highlight: { [self] in
                    showingChairStandTestsHighlighted.toggle()
                }, individualize: { [self] in
                    showingIndividualChairStandTests.toggle()
                }, expand: { [self] in
                    showingIndividualChairStandTestsExpanded.toggle()
                })
        }
        
        if let tests = BatteryProgressModel.lastTestsStatus {
            showBullets(for: tests)
        }
        
        // Animate the new bullets to appear after completing the last test(s).
        showBullets(for: battery.tests, animating: true)
        
        // Animate highlighting and expanding if necessary and the progress line.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            animate()
        }
    }
    
    // MARK: - Private Functions
    
    private func show(animating: Bool = false, highlight: @escaping () -> (), individualize: @escaping () -> (), expand: @escaping () -> ()) {
        if animating {
            withAnimation(.spring()){ highlight() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()){ individualize() }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ expand() }
                FeedbackGenerator.haptic(.soft)
            }
        } else {
            highlight()
            individualize()
            expand()
        }
    }
    
    private func hide(animating: Bool = false, highlight: @escaping () -> (), individualize: @escaping () -> (), expand: @escaping () -> ()) {
        if animating {
            withAnimation(.spring()){ expand() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring()){ individualize() }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ highlight() }
            }
        } else {
            expand()
            individualize()
            highlight()
        }
    }
    
    private func showBullets(for tests: [Test], animating: Bool = false) {
        tests.forEach { test in
            if let test = test as? BalanceTest {
                switch test.pose {
                case .side_by_side:
                    sideBySideBulletColor = bulletColor(for: test)
                    if animating {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ sideBySideFinished = test.isFinished }
                        }
                    } else {
                        sideBySideFinished = test.isFinished
                    }
                case .semi_tandem:
                    semiTandemBulletColor = bulletColor(for: test)
                    if animating {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ semiTandemFinished = test.isFinished }
                        }
                    } else {
                        semiTandemFinished = test.isFinished
                    }
                case .tandem:
                    tandemBulletColor = bulletColor(for: test)
                    if animating {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ tandemFinished = test.isFinished }
                        }
                    } else {
                        tandemFinished = test.isFinished
                    }
                }
            }
            if let test = test as? GaitTest {
                if test.number == 1 {
                    firstGaitBulletColor = bulletColor(for: test)
                    if animating {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ firstGaitFinished = test.isFinished }
                        }
                    } else {
                        firstGaitFinished = test.isFinished
                    }
                } else {
                    secondGaitBulletColor = bulletColor(for: test)
                    if animating {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ secondGaitFinished = test.isFinished }
                        }
                    } else {
                        secondGaitFinished = test.isFinished
                    }
                }
            }
            if let test = test as? ChairStandTest {
                switch test.testType {
                case .single:
                    singleChairStandBulletColor = bulletColor(for: test)
                    if animating {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ singleChairStandFinished = test.isFinished }
                        }
                    } else {
                        singleChairStandFinished = test.isFinished
                    }
                case .repeated:
                    repeatedChairStandBulletColor = bulletColor(for: test)
                    if animating {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                            withAnimation(.interpolatingSpring(stiffness: 100, damping: 7)){ repeatedChairStandFinished = test.isFinished }
                        }
                    } else {
                        repeatedChairStandFinished = test.isFinished
                    }
                }
            }
        }
    }
    
    func animate() {
        guard let nextTest = battery.nextTest else {
            // Battery is complete, last test was the final test.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                hide(animating: true,
                     highlight: { [self] in
                    showingChairStandTestsHighlighted.toggle()
                }, individualize: { [self] in
                    showingIndividualChairStandTests.toggle()
                }, expand: { [self] in
                    showingIndividualChairStandTestsExpanded.toggle()
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    withAnimation(.easeOut(duration: 2)) {
                        animating = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [self] in
                    animationFinished = true
                }
            }
            return
        }
        
        guard let lastTest = battery.lastTest else {
            // Battery started, next test is the first test.
            show(animating: true,
                 highlight: { [self] in
                showingBalanceTestsHighlighted.toggle()
            }, individualize: { [self] in
                showingIndividualBalanceTests.toggle()
            }, expand: { [self] in
                showingIndividualBalanceTestsExpanded.toggle()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                withAnimation(.easeOut(duration: 2)) {
                    animating = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                animationFinished = true
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if nextTest is GaitTest && !(lastTest is GaitTest) {
                // Last test was a balance test and next test is the first gait speed test.
                hide(animating: true,
                     highlight: { [self] in
                    showingBalanceTestsHighlighted.toggle()
                    showingGaitTestsHighlighted.toggle()
                }, individualize: { [self] in
                    showingIndividualBalanceTests.toggle()
                }, expand: { [self] in
                    showingIndividualBalanceTestsExpanded.toggle()
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    show(animating: true,
                         highlight: {
                    }, individualize: { [self] in
                        showingIndividualGaitTests.toggle()
                    }, expand: { [self] in
                        showingIndividualGaitTestsExpanded.toggle()
                    })
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                    withAnimation(.easeOut(duration: 2)) {
                        animating = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
                    animationFinished = true
                }
                return
            }
            if nextTest is ChairStandTest && !(lastTest is ChairStandTest) {
                // Last test was gait speed test and next test is the single chair stand test.
                hide(animating: true,
                     highlight: { [self] in
                    showingGaitTestsHighlighted.toggle()
                    showingChairStandTestsHighlighted.toggle()
                }, individualize: { [self] in
                    showingIndividualGaitTests.toggle()
                }, expand: { [self] in
                    showingIndividualGaitTestsExpanded.toggle()
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    show(animating: true,
                         highlight: {
                    }, individualize: { [self] in
                        showingIndividualChairStandTests.toggle()
                    }, expand: { [self] in
                        showingIndividualChairStandTestsExpanded.toggle()
                    })
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                    withAnimation(.easeOut(duration: 2)) {
                        animating = true
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
                    animationFinished = true
                }
                return
            }
            
            // Last test and next test are in the same category, no need to shrink or expand categories.
            withAnimation(.easeOut(duration: 1)) {
                animating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                animationFinished = true
            }
        }
    }
    
    private func bulletColor(for test: Test) -> Color {
        switch test.state {
        case .upcoming:
            return .white
        case .skipped:
            return .gray
        case .attempted:
            return .blue
        }
    }
}
