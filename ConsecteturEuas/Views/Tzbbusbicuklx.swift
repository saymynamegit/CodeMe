import SwiftUI
import UIKit

struct ZoomPanView<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let shouldRecognizeSimultaneously: Bool
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    private let doubleTapScale: CGFloat = 2.0
    
    init(@ViewBuilder content: () -> Content,
         scale: Binding<CGFloat>,
         offset: Binding<CGSize>,
         shouldRecognizeSimultaneously: Bool = false) {
        self.content = content()
        self._scale = scale
        self._offset = offset
        self.shouldRecognizeSimultaneously = shouldRecognizeSimultaneously
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = minScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.clipsToBounds = false
        
        // Add double tap gesture recognizer
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Configure the content view
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = UIColor(Color.wavcpwugess)
        scrollView.addSubview(hostedView)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content
        context.coordinator.shouldRecognizeSimultaneously = shouldRecognizeSimultaneously
        
        // Update zoom scale if needed
        if abs(uiView.zoomScale - scale) > 0.01 {
            uiView.setZoomScale(scale, animated: true)
        }
        
        // Update content offset if needed
        let currentOffset = CGSize(width: uiView.contentOffset.x, height: uiView.contentOffset.y)
        if abs(currentOffset.width - offset.width) > 1 || abs(currentOffset.height - offset.height) > 1 {
            uiView.setContentOffset(CGPoint(x: offset.width, y: offset.height), animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, content: content)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var parent: ZoomPanView
        let hostingController: UIHostingController<Content>
        var shouldRecognizeSimultaneously: Bool = false
        
        init(parent: ZoomPanView, content: Content) {
            self.parent = parent
            self.hostingController = UIHostingController(rootView: content)
            super.init()
        }
        
        // MARK: - UIScrollViewDelegate
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            parent.scale = scrollView.zoomScale
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.offset = CGSize(width: scrollView.contentOffset.x, height: scrollView.contentOffset.y)
        }
        
        // MARK: - Gesture Handling
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            let scrollView = gesture.view as! UIScrollView
            let pointInView = gesture.location(in: hostingController.view)
            
            let newScale: CGFloat
            if scrollView.zoomScale > parent.minScale + 0.1 {
                newScale = parent.minScale
            } else {
                newScale = parent.doubleTapScale
            }
            
            let scrollViewSize = scrollView.bounds.size
            let w = scrollViewSize.width / newScale
            let h = scrollViewSize.height / newScale
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            
            let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
            scrollView.zoom(to: rectToZoomTo, animated: true)
        }
        
        // MARK: - UIGestureRecognizerDelegate
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                              shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return shouldRecognizeSimultaneously
        }
    }
}
