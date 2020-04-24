//
//  Created by Shin Yamamoto on 2019/06/27.
//  Copyright © 2019 scenee. All rights reserved.
//

import XCTest
@testable import FloatingPanel

class FloatingPanelLayoutTests: XCTestCase {
    var fpc: FloatingPanelController!
    override func setUp() {
        fpc = FloatingPanelController(delegate: nil)
        fpc.loadViewIfNeeded()
        fpc.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
    }
    override func tearDown() {}

    func test_layoutAdapter_topAndBottomMostState() {
        XCTAssertEqual(fpc.floatingPanel.layoutAdapter.edgeMostState, .full)
        XCTAssertEqual(fpc.floatingPanel.layoutAdapter.edgeLeastState, .tip)

        class FloatingPanelLayoutWithHidden: FloatingPanelLayout {
            var stateAnchors: [FloatingPanelState: FloatingPanelLayoutAnchoring]  {
                return [
                    .full: FloatingPanelLayoutAnchor(absoluteInset: 18.0, edge: .top, referenceGuide: .safeArea),
                    .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
                    .hidden: FloatingPanelLayoutAnchor.hidden
                ]
            }
            let initialState: FloatingPanelState = .hidden
            let anchoredPosition: FloatingPanelPosition = .bottom
        }
        class FloatingPanelLayout2Positions: FloatingPanelLayout {
            var stateAnchors: [FloatingPanelState: FloatingPanelLayoutAnchoring]  {
                return [
                    .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
                    .tip: FloatingPanelLayoutAnchor(absoluteInset: 69.0, edge: .bottom, referenceGuide: .safeArea),
                ]
            }
            let initialState: FloatingPanelState = .tip
            let anchoredPosition: FloatingPanelPosition = .bottom
        }
        fpc.layout = FloatingPanelLayoutWithHidden()
        XCTAssertEqual(fpc.floatingPanel.layoutAdapter.edgeMostState, .full)
        XCTAssertEqual(fpc.floatingPanel.layoutAdapter.edgeLeastState, .hidden)

        fpc.layout = FloatingPanelLayout2Positions()
        XCTAssertEqual(fpc.floatingPanel.layoutAdapter.edgeMostState, .half)
        XCTAssertEqual(fpc.floatingPanel.layoutAdapter.edgeLeastState, .tip)
    }

    func test_layoutSegment_3position() {
        class FloatingPanelLayout3Positions: FloatingPanelTestLayout {
            override var initialState: FloatingPanelState  { .half }
        }

        fpc.layout = FloatingPanelLayout3Positions()

        let fullPos = fpc.surfaceEdgeLocation(for: .full).y
        let halfPos = fpc.surfaceEdgeLocation(for: .half).y
        let tipPos = fpc.surfaceEdgeLocation(for: .tip).y

        let minPos = CGFloat.leastNormalMagnitude
        let maxPos = CGFloat.greatestFiniteMagnitude

        assertLayoutSegment(fpc.floatingPanel, with: [
            (#line, pos: minPos, forwardY: true, lower: nil, upper: .full),
            (#line, pos: minPos, forwardY: false, lower: nil, upper: .full),
            (#line, pos: fullPos, forwardY: true, lower: .full, upper: .half),
            (#line, pos: fullPos, forwardY: false, lower: nil,  upper: .full),
            (#line, pos: halfPos, forwardY: true, lower: .half, upper: .tip),
            (#line, pos: halfPos, forwardY: false, lower: .full,  upper: .half),
            (#line, pos: tipPos, forwardY: true, lower: .tip, upper: nil),
            (#line, pos: tipPos, forwardY: false, lower: .half,  upper: .tip),
            (#line, pos: maxPos, forwardY: true, lower: .tip, upper: nil),
            (#line, pos: maxPos, forwardY: false, lower: .tip, upper: nil),
            ])
    }

    func test_layoutSegment_2positions() {
        class FloatingPanelLayout2Positions: FloatingPanelTestLayout {
            override var initialState: FloatingPanelState  { .half }
            override var stateAnchors: [FloatingPanelState : FloatingPanelLayoutAnchoring]
                { super.stateAnchors.filter { (key, _) in key != .tip } }
        }

        fpc.layout = FloatingPanelLayout2Positions()

        let fullPos = fpc.surfaceEdgeLocation(for: .full).y
        let halfPos = fpc.surfaceEdgeLocation(for: .half).y

        let minPos = CGFloat.leastNormalMagnitude
        let maxPos = CGFloat.greatestFiniteMagnitude

        assertLayoutSegment(fpc.floatingPanel, with: [
            (#line, pos: minPos, forwardY: true, lower: nil, upper: .full),
            (#line, pos: minPos, forwardY: false, lower: nil, upper: .full),
            (#line, pos: fullPos, forwardY: true, lower: .full, upper: .half),
            (#line, pos: fullPos, forwardY: false, lower: nil,  upper: .full),
            (#line, pos: halfPos, forwardY: true, lower: .half, upper: nil),
            (#line, pos: halfPos, forwardY: false, lower: .full,  upper: .half),
            (#line, pos: maxPos, forwardY: true, lower: .half, upper: nil),
            (#line, pos: maxPos, forwardY: false, lower: .half, upper: nil),
            ])
    }

    func test_layoutSegment_1positions() {
        class FloatingPanelLayout1Positions: FloatingPanelTestLayout {
            override var initialState: FloatingPanelState  { .full }
            override var stateAnchors: [FloatingPanelState : FloatingPanelLayoutAnchoring]
                { super.stateAnchors.filter { (key, _) in key == .full } }
        }

        fpc.layout = FloatingPanelLayout1Positions()

        let fullPos = fpc.surfaceEdgeLocation(for: .full).y

        let minPos = CGFloat.leastNormalMagnitude
        let maxPos = CGFloat.greatestFiniteMagnitude

        assertLayoutSegment(fpc.floatingPanel, with: [
            (#line, pos: minPos, forwardY: true, lower: nil, upper: .full),
            (#line, pos: minPos, forwardY: false, lower: nil, upper: .full),
            (#line, pos: fullPos, forwardY: true, lower: .full, upper: nil),
            (#line, pos: fullPos, forwardY: false, lower: nil,  upper: .full),
            (#line, pos: maxPos, forwardY: true, lower: .full, upper: nil),
            (#line, pos: maxPos, forwardY: false, lower: .full, upper: nil),
            ])
    }

    func test_updateInteractiveEdgeConstraint() {
        fpc.showForTest()
        fpc.move(to: .full, animated: false)

        fpc.floatingPanel.layoutAdapter.startInteraction(at: fpc.state)
        fpc.floatingPanel.layoutAdapter.startInteraction(at: fpc.state) // Should be ignore

        let fullPos = fpc.surfaceEdgeLocation(for: .full).y
        let tipPos = fpc.surfaceEdgeLocation(for: .tip).y

        var next: CGFloat

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: -100.0, overflow: false, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, fullPos)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: 100.0, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, fullPos + 100.0)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: tipPos - fullPos, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, tipPos)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: tipPos - fullPos + 100.0, overflow: false, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, tipPos)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: tipPos - fullPos + 100.0, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, tipPos + 100.0)

        fpc.floatingPanel.layoutAdapter.endInteraction(at: fpc.state)
    }

    func test_updateInteractiveEdgeConstraint_bottomEdge() {
        fpc.layout = FloatingPanelTop2BottomTestLayout()
        fpc.showForTest()
        fpc.move(to: .tip, animated: false)
        XCTAssertEqual(fpc.surfaceView.frame, CGRect(x: 0.0, y: -667.0 + 60.0, width: 375.0, height: 667))
        XCTAssertEqual(fpc.surfaceView.containerView.frame, CGRect(x: 0.0, y: -667.0,
                                                                   width: 375.0, height: 667 * 2.0))

        fpc.floatingPanel.layoutAdapter.startInteraction(at: fpc.state)
        fpc.floatingPanel.layoutAdapter.startInteraction(at: fpc.state) // Should be ignore

        XCTAssertEqual(fpc.floatingPanel.layoutAdapter.interactionEdgeConstraint?.constant, 60.0)

        let fullPos = fpc.surfaceEdgeLocation(for: .full).y
        let tipPos = fpc.surfaceEdgeLocation(for: .tip).y

        var pre: CGFloat
        var next: CGFloat
        pre = fpc.surfaceView.frame.maxY
        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: -100.0, overflow: false, with: fpc.behavior)
        next = fpc.surfaceView.frame.maxY
        XCTAssertEqual(next, pre)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: 100.0, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.maxY
        XCTAssertEqual(next, tipPos + 100.0)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: fullPos - tipPos, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.maxY
        XCTAssertEqual(next, fullPos)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: fullPos - tipPos + 100, overflow: false, with: fpc.behavior)
        next = fpc.surfaceView.frame.maxY
        XCTAssertEqual(next, fullPos)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: fullPos - tipPos + 100, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.maxY
        XCTAssertEqual(next, fullPos + 100.0)

        fpc.floatingPanel.layoutAdapter.endInteraction(at: fpc.state)
    }

    func test_updateInteractiveEdgeConstraintWithHidden() {
        class FloatingPanelLayout2Positions: FloatingPanelLayout {
            var stateAnchors: [FloatingPanelState: FloatingPanelLayoutAnchoring]  {
                return [
                    .full: FloatingPanelLayoutAnchor(absoluteInset: 18.0, edge: .bottom, referenceGuide: .safeArea),
                    .hidden: FloatingPanelLayoutAnchor.hidden,
                ]
            }
            let initialState: FloatingPanelState = .hidden
            let anchoredPosition: FloatingPanelPosition = .bottom
        }
        fpc.layout = FloatingPanelLayout2Positions()
        fpc.showForTest()
        fpc.move(to: .full, animated: false)

        fpc.floatingPanel.layoutAdapter.startInteraction(at: fpc.state)

        let fullPos = fpc.surfaceEdgeLocation(for: .full).y
        let hiddenPos = fpc.surfaceEdgeLocation(for: .hidden).y

        var next: CGFloat

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: -100.0, overflow: false, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, fullPos)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: -100.0, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, fullPos - 100.0)

        fpc.floatingPanel.layoutAdapter.updateInteractiveEdgeConstraint(diff: hiddenPos - fullPos + 100.0, overflow: true, with: fpc.behavior)
        next = fpc.surfaceView.frame.minY
        XCTAssertEqual(next, hiddenPos + 100.0)

        fpc.floatingPanel.layoutAdapter.endInteraction(at: fpc.state)
    }

    //TODO
    func test_updateInteractiveEdgeConstraintWithHidden_bottomEdge() {
    }

    func test_positionY() {
        fpc = CustomSafeAreaFloatingPanelController()
        fpc.loadViewIfNeeded()
        fpc.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)

        class MyFloatingPanelFullLayout: FloatingPanelTestLayout {}
        class MyFloatingPanelSafeAreaLayout: FloatingPanelTestLayout {
            override var referenceGuide: FloatingPanelLayoutReferenceGuide {
                return .safeArea
            }
        }

        fpc.layout = MyFloatingPanelFullLayout()
        fpc.showForTest()

        let bounds = fpc.view!.bounds
        XCTAssertEqual(fpc.layout.stateAnchors.filter({ $0.value.referenceGuide != .superview }).count, 0)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .full).y, fpc.layout.stateAnchors[.full]!.value)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .half).y, bounds.height - fpc.layout.stateAnchors[.half]!.value)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .tip).y, bounds.height - fpc.layout.stateAnchors[.tip]!.value)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .hidden).y, bounds.height)

        fpc.layout = MyFloatingPanelSafeAreaLayout()

        XCTAssertEqual(fpc.layout.stateAnchors.filter({ $0.value.referenceGuide != .safeArea }).count, 0)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .full).y, fpc.layout.stateAnchors[.full]!.value + fpc.fp_safeAreaInsets.top)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .half).y, bounds.height - fpc.layout.stateAnchors[.half]!.value + fpc.fp_safeAreaInsets.bottom)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .tip).y, bounds.height - fpc.layout.stateAnchors[.tip]!.value +  fpc.fp_safeAreaInsets.bottom)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .hidden).y, bounds.height)
    }

    func test_positionY_bottomEdge() {
        fpc = CustomSafeAreaFloatingPanelController()
        fpc.loadViewIfNeeded()
        fpc.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)

        class MyFloatingPanelFullLayout: FloatingPanelTop2BottomTestLayout { }
        class MyFloatingPanelSafeAreaLayout: FloatingPanelTop2BottomTestLayout {
            override var referenceGuide: FloatingPanelLayoutReferenceGuide {
                return .safeArea
            }
        }
        fpc.layout = MyFloatingPanelFullLayout()
        fpc.showForTest()

        let bounds = fpc.view!.bounds
        XCTAssertEqual(fpc.layout.stateAnchors.filter({ $0.value.referenceGuide != .superview }).count, 0)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .full).y, bounds.height - fpc.layout.stateAnchors[.full]!.value)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .half).y, fpc.layout.stateAnchors[.half]!.value)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .tip).y,  fpc.layout.stateAnchors[.tip]!.value)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .hidden).y, 0.0)


        fpc.layout = MyFloatingPanelSafeAreaLayout()

        XCTAssertEqual(fpc.layout.stateAnchors.filter({ $0.value.referenceGuide != .safeArea }).count, 0)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .full).y, bounds.height - fpc.layout.stateAnchors[.full]!.value + fpc.fp_safeAreaInsets.bottom)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .half).y, fpc.layout.stateAnchors[.half]!.value + fpc.fp_safeAreaInsets.top)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .tip).y, fpc.layout.stateAnchors[.tip]!.value +  fpc.fp_safeAreaInsets.top)
        XCTAssertEqual(fpc.surfaceEdgeLocation(for: .hidden).y, 0.0)
    }
}

private typealias LayoutSegmentTestParameter = (UInt, pos: CGFloat, forwardY: Bool, lower: FloatingPanelState?, upper: FloatingPanelState?)
private func assertLayoutSegment(_ floatingPanel: FloatingPanelCore, with params: [LayoutSegmentTestParameter]) {
    params.forEach { (line, pos, forwardY, lowr, upper) in
        let segument = floatingPanel.layoutAdapter.segument(at: pos, forward: forwardY)
        XCTAssertEqual(segument.lower, lowr, line: line)
        XCTAssertEqual(segument.upper, upper, line: line)
    }
}

private class CustomSafeAreaFloatingPanelController: FloatingPanelController {
    override var fp_safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 64.0, left: 0.0, bottom: 0.0, right: 34.0)
    }
}
