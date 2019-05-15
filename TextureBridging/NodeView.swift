
import UIKit
import AsyncDisplayKit

open class NodeView<D: ASDisplayNode>: UILabel /* To use `textRect` method */ {
  
  // MARK: - Properties
  
  public let node: D
  private let wrapperNode: WrapperNode
  
  // MARK: - Initializers
  
  public init(node: D, frame: CGRect = .zero) {
    
    self.node = node
    self.wrapperNode = WrapperNode(node: node)
    
    super.init(frame: frame)
    
    // To call `textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int)`
    numberOfLines = 0
    isUserInteractionEnabled = true
    
    addSubnode(wrapperNode)
    
    wrapperNode.calculatedLayoutDidChangeHandler = { [weak self] in
      Log.debug("calculatedLayoutDidChangeHandler")
      self?.invalidateIntrinsicContentSize()
    }
    
    wrapperNode.layoutDidFinishHandler = { [weak self] in
      Log.debug("layoutDidFinishHandler")
      self?.invalidateIntrinsicContentSize()
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    
    let validate: (_ value: CGFloat, _ fallback: CGFloat) -> CGFloat = { value, fallback in
      // To guard crash inside Texture
      guard ASPointsValidForSize(value) else {
        return fallback
      }
      return value
    }
    
    var range = ASSizeRangeUnconstrained
    
    range.max.width = validate(bounds.width, 10000)
    
    let r = wrapperNode.layoutThatFits(range)
    return CGRect(origin: .zero, size: r.size)
  }
  
  // MARK: - Functions
  
  open override func layoutSubviews() {
    
    super.layoutSubviews()
    
    wrapperNode.frame = bounds
  }
}

private class WrapperNode : ASDisplayNode {
  
  var calculatedLayoutDidChangeHandler: () -> Void = {}
  var layoutDidFinishHandler: () -> Void = {}
  
  let node: ASDisplayNode
  
  init(node: ASDisplayNode) {
    
    self.node = node
    
    super.init()
    addSubnode(node)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASWrapperLayoutSpec(layoutElement: node)
  }
  
  override func calculatedLayoutDidChange() {
    super.calculatedLayoutDidChange()
    calculatedLayoutDidChangeHandler()
  }
  
  override func layoutDidFinish() {
    super.layoutDidFinish()
    layoutDidFinishHandler()
  }
  
  override func layout() {
    super.layout()
  }
}

