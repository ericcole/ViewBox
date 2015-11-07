//
//  ViewBox.swift
//  ViewBox
//
//  Created by Eric Cole on 10/1/15.
//  Copyright © 2015 Balance Software. All rights reserved.
//

import UIKit

public struct ViewBox {
	public var center:CGPoint
	public var size:CGSize
	
	public init( view:UIView ) { center = view.center; size = view.frame.size }
	public init( frame:CGRect ) { center = frame.center; size = frame.size }
	public init( origin o:CGPoint, size s:CGSize ) { center = CGPoint( x:o.x + s.width * 0.5, y:o.y + s.height * 0.5 ); size = s }
	public init( origin x:CGFloat, _ y:CGFloat, size width:CGFloat, _ height:CGFloat ) { center = CGPoint( x:x + width * 0.5, y:y + height * 0.5 ); size = CGSize( width:width, height:height ) }
	public init( center c:CGPoint, size s:CGSize ) { center = c; size = s }
	public init( size s:CGSize ) { center = CGPoint( x:s.width * 0.5, y:s.height * 0.5 ); size = s }
	
	/// ViewBox with even size and integral origin
	public var even:ViewBox { return ViewBox( center:center.integral, size:size.evenSize ) }
	
	/// ViewBox with integral size and origin as CGRectIntegral
	public var integral:ViewBox { return ViewBox( frame:frame.integral ) }
	
	/// ViewBox with integral size and origin
	public var interface:ViewBox { let s = size.integral; return ViewBox( center:center.interfaceCenterForSize(s), size:s ) }
	
	/// true if width and height are greater than zero
	public var isPositive:Bool { return size.isPositive }
	
	/// CGPoint origin as CGRect
	public var origin:CGPoint {
		get { return CGPoint( x:center.x - size.width * 0.5, y:center.y - size.height * 0.5 ) }
		set { center = CGPoint( x:newValue.x + size.width * 0.5, y:newValue.y + size.width * 0.5 ) }
	}
	
	/// CGRect
	public var frame:CGRect {
		get { return CGRect( origin:origin, size:size ) }
		set { size = newValue.size; origin = newValue.origin }
	}
	
	/// CGRect with even size and integral origin
	public var evenFrame:CGRect {
		get { return CGRect( center:center.integral, size:size.evenSize ) }
		set { size = newValue.size.evenSize; center = newValue.center.integral }
	}
	
	/// CGRect with integral size and origin
	public var interfaceFrame:CGRect {
		get { let s = size.integral; return CGRect( center:center.interfaceCenterForSize(s), size:s ) }
		set { size = newValue.size.integral; center = newValue.center.interfaceCenterForSize(size) }
	}
	
	/// true if boxes are nearly identical within tolerance
	public func isNear( other:ViewBox, tolerance:CGFloat = UI.tolerance ) -> Bool {
		return center.isNear( other.center, tolerance:tolerance ) && size.isNear( other.size, tolerance:tolerance )
	}
}

//	MARK: Adjustment and Calculation

public extension ViewBox {
	/// ViewBox copy with size scaled by sx and sz
	public func scaled( sx:CGFloat, _ sy:CGFloat ) -> ViewBox { return ViewBox( center:center, size:CGSize( width:size.width * sx, height:size.height * sy ) ) }
	
	/// ViewBox copy with size inset by dx and dy
	public func inset( dx:CGFloat, _ dy:CGFloat ) -> ViewBox { return ViewBox( center:center, size:CGSize( width:size.width - dx*2, height:size.height - dy*2 ) ) }
	
	/// ViewBox copy with edges inset by insets
	public func inset( insets:UIEdgeInsets ) -> ViewBox { return ViewBox( frame:UIEdgeInsetsInsetRect( frame, insets ) ) }
	
	/// ViewBox copy with center offset by dx and dy
	public func offset( dx:CGFloat, _ dy:CGFloat = 0 ) -> ViewBox { return ViewBox( center:CGPoint( x:center.x + dx, y:center.y + dy ), size:size ) }
	
	/// ViewBox copy with center advanced in interface direction by dx and dy
	public func advance( dx:CGFloat, _ dy:CGFloat = 0 ) -> ViewBox { return offset( UI.isRTL ? -dx : dx, dy ) }
	
	/// ViewBox copy with center moved down by amount
	public func down( dy:CGFloat ) -> ViewBox { return offset( 0, dy ) }
	
	/// ViewBox copy as CGRect division
	public func slice( distance:CGFloat, edge:CGRectEdge ) -> ViewBox { return ViewBox( frame:frame.divide( distance, fromEdge:edge ).slice ) }
	
	/// ViewBox that wholly contains both boxes
	public func union( other:ViewBox ) -> ViewBox { return ViewBox( frame:CGRectUnion( frame, other.frame ) ) }
	
	/// ViewBox contained by both boxes
	public func intersect( other:ViewBox ) -> ViewBox { return ViewBox( frame:CGRectIntersection( frame, other.frame ) ) }
	
	/// true if area covered by both boxes is not empty
	public func intersects( other:ViewBox ) -> Bool { return CGRectIntersectsRect( frame, other.frame ) }
	
	/// true if ViewBox wholly contains other box
	public func contains( other:ViewBox ) -> Bool { return CGRectContainsRect( frame, other.frame )  }
	
	/// true if ViewBox contains point
	public func contains( point:CGPoint ) -> Bool { return CGRectContainsPoint( frame, point ) }
}

//	MARK: Edge and Corner Accessors

public extension ViewBox {
	public enum EdgePosition : Int {
		case Center = 8, Left = 0, Right = 1, Top = 2, Bottom = 3, Leading = 4, Trailing = 5
		
		var scalar:CGFloat {
			return ( rawValue & ~7 ) == 0 ? ( concrete.rawValue & 1 ) == 0 ? -0.5 : 0.5 : 0.0
		}
		
		var concrete:EdgePosition {
			return ( rawValue & ~3 ) == 4 ? EdgePosition( rawValue: ( rawValue & 3 ) ^ ( UI.isRTL ? 1 : 0 ) )! : self
		}
	}
	
	public var width:CGFloat { get { return size.width } set { size.width = newValue } }
	public var height:CGFloat { get { return size.height } set { size.height = newValue } }
	
	public var top:CGFloat { get { return center.y - size.height * 0.5 } set { center.y = newValue + size.height + 0.5 } }
	public var left:CGFloat { get { return center.x - size.width * 0.5 } set { center.x = newValue + size.width + 0.5 } }
	public var bottom:CGFloat { get { return center.y + size.height * 0.5 } set { center.y = newValue - size.height + 0.5 } }
	public var right:CGFloat { get { return center.x + size.width * 0.5 } set { center.x = newValue - size.width + 0.5 } }
	public var leading:CGFloat { get { return center.x - size.width * ( UI.isRTL ? -0.5 : 0.5 ) } set { center.x = newValue + size.width + ( UI.isRTL ? -0.5 : 0.5 ) } }
	public var trailing:CGFloat { get { return center.x + size.width * ( UI.isRTL ? -0.5 : 0.5 ) } set { center.x = newValue - size.width + ( UI.isRTL ? -0.5 : 0.5 ) } }
	
	public var topLeft:CGPoint { get { return edgePoint( h:.Left, v:.Top ) } set { center = centerWithEdgePoint( newValue, h:.Left, v:.Top ) } }
	public var topRight:CGPoint { get { return edgePoint( h:.Right, v:.Top ) } set { center = centerWithEdgePoint( newValue, h:.Right, v:.Top ) } }
	public var bottomLeft:CGPoint { get { return edgePoint( h:.Left, v:.Bottom ) } set { center = centerWithEdgePoint( newValue, h:.Left, v:.Bottom ) } }
	public var bottomRight:CGPoint { get { return edgePoint( h:.Right, v:.Bottom ) } set { center = centerWithEdgePoint( newValue, h:.Right, v:.Bottom ) } }
	public var topLeading:CGPoint { get { return edgePoint( h:.Leading, v:.Top ) } set { center = centerWithEdgePoint( newValue, h:.Leading, v:.Top ) } }
	public var topTrailing:CGPoint { get { return edgePoint( h:.Trailing, v:.Top ) } set { center = centerWithEdgePoint( newValue, h:.Trailing, v:.Top ) } }
	public var bottomLeading:CGPoint { get { return edgePoint( h:.Leading, v:.Bottom ) } set { center = centerWithEdgePoint( newValue, h:.Leading, v:.Bottom ) } }
	public var bottomTrailing:CGPoint { get { return edgePoint( h:.Trailing, v:.Bottom ) } set { center = centerWithEdgePoint( newValue, h:.Trailing, v:.Bottom ) } }
	
	public var centerLeft:CGPoint { get { return edgePoint( h:.Left, v:.Center ) } set { center = centerWithEdgePoint( newValue, h:.Left, v:.Center ) } }
	public var centerRight:CGPoint { get { return edgePoint( h:.Right, v:.Center ) } set { center = centerWithEdgePoint( newValue, h:.Right, v:.Center ) } }
	public var centerTop:CGPoint { get { return edgePoint( h:.Center, v:.Top ) } set { center = centerWithEdgePoint( newValue, h:.Center, v:.Top ) } }
	public var centerBottom:CGPoint { get { return edgePoint( h:.Center, v:.Bottom ) } set { center = centerWithEdgePoint( newValue, h:.Center, v:.Bottom ) } }
	public var centerLeading:CGPoint { get { return edgePoint( h:.Leading, v:.Center ) } set { center = centerWithEdgePoint( newValue, h:.Leading, v:.Center ) } }
	public var centerTrailing:CGPoint { get { return edgePoint( h:.Trailing, v:.Center ) } set { center = centerWithEdgePoint( newValue, h:.Trailing, v:.Center ) } }
	
	public func edgePoint( h h:EdgePosition, v:EdgePosition ) -> CGPoint {
		return CGPoint( x:center.x + size.width * h.scalar, y:center.y + size.height * v.scalar )
	}
	
	public func centerWithEdgePoint( p:CGPoint, h:EdgePosition, v:EdgePosition ) -> CGPoint {
		return CGPoint( x:p.x - size.width * h.scalar, y:p.y - size.height * v.scalar )
	}
	
	public subscript( h:EdgePosition, v:EdgePosition ) -> CGPoint {
		get { return edgePoint( h:h, v:v ) }
		set { center = centerWithEdgePoint( newValue, h:h, v:v ) }
	}
	
	/// ViewBox copy with edge shifted by amount
	public func trimming( edge:EdgePosition, by amount:CGFloat ) -> ViewBox {
		var result = self; result.trim( edge, by:amount ); return result
	}
	
	/// ViewBox copy with edge shifted to position
	public func trimming( edge:EdgePosition, to position:CGFloat ) -> ViewBox {
		var result = self; result.trim( edge, to:position ); return result
	}
	
	/// shift edge by amount
	public mutating func trim( edge:EdgePosition, by amount:CGFloat ) {
		switch edge.concrete {
		case .Left: center.x += amount * 0.5; size.width -= amount
		case .Right: center.x -= amount * 0.5; size.width -= amount
		case .Top: origin.y += amount * 0.5; size.height -= amount
		case .Bottom: origin.y -= amount * 0.5; size.height -= amount
		default: break
		}
	}
	
	/// shift edge to position
	public mutating func trim( edge:EdgePosition, to value:CGFloat ) {
		switch edge.concrete {
		case .Left: size.width = center.x + size.width * 0.5 - value; center.x = value + size.width * 0.5
		case .Right: size.width = value - center.x + size.width * 0.5; center.x = value - size.width * 0.5
		case .Top: size.height = center.y + size.height * 0.5 - value; center.y = value + size.height * 0.5
		case .Bottom: size.height = value - center.y + size.height * 0.5; center.y = value - size.height * 0.5
		default: break
		}
	}
}

//	MARK: Sides and Tips as Properties

public extension ViewBox {
	/// ViewBox with edges
	public init( sides:ClosedInterval<CGFloat>, tips:ClosedInterval<CGFloat> ) {
		size = CGSize( width:fabs( sides.end - sides.start ), height:fabs( tips.end - tips.start ) )
		center = CGPoint( x:( sides.end + sides.start )*0.5, y:( tips.end + tips.start ) * 0.5 )
	}
	
	/// ViewBox top and bottom edges as closed interval
	public var tips:ClosedInterval<CGFloat> {
		get { return top...bottom }
		set {
			size.height = fabs( newValue.end - newValue.start )
			center.y = ( newValue.end + newValue.start ) * 0.5
		}
	}
	
	/// ViewBox leading and trailing edges as closed interval
	public var sides:ClosedInterval<CGFloat> {
		get { return left...right }
		set {
			size.width = fabs( newValue.end - newValue.start )
			center.x = ( newValue.end + newValue.start ) * 0.5
		}
	}
}

//	MARK: Edge and Center Properties

public extension ViewBox {
	public enum Property : Int {
		case Left = 0, Top = 2,
			Right = 1, Bottom = 3,
			Leading = 4, Trailing = 5,
			CenterX = 8, CenterY = 10,
			Width = 9, Height = 11
		
		var isPosition:Bool { return ( rawValue & 9 ) != 9 }
		var isVertical:Bool { return ( rawValue & 2 ) != 0 }
		var isAbstract:Bool { return ( rawValue & 4 ) != 0 }
		var concrete:Property { return isAbstract ? Property( rawValue:( rawValue ^ ( UI.isRTL ? 5 : 4 ) ) )! : self }
	}
	
	/// ViewBox property
	public func property( property:Property ) -> CGFloat {
		switch property.concrete {
		case .Leading, .Trailing: return 0
		case .Left: return center.x - size.width * 0.5
		case .Right: return center.x + size.width * 0.5
		case .CenterX: return center.x
		case .Width: return size.width
		case .Top: return center.y - size.height * 0.5
		case .Bottom: return center.y + size.height * 0.5
		case .CenterY: return center.y
		case .Height: return size.height
		}
	}
	
	/// assign value to property optionally pinning related property
	public mutating func assignProperty( property:Property, value:CGFloat, pinning:Property? = nil ) {
		let pin = pinning?.concrete ?? property
		
		switch property.concrete {
		case .Leading, .Trailing: break
		case .Left:
			if .Right == pin { size.width = right - value }
			else if .CenterX == pin { size.width = ( center.x - value ) * 2.0 }
			center.x = value + size.width * 0.5
		case .Right:
			if .Left == pin { size.width = value - left }
			else if .CenterX == pin { size.width = ( value - center.x ) * 2.0 }
			center.x = value - size.width * 0.5
		case .CenterX:
			if .Left == pin { size.width = ( value - left ) * 2.0 }
			else if .Right == pin { size.width = ( right - value ) * 2.0 }
			center.x = value
		case .Width:
			if .Left == pin { center.x += ( value - size.width ) * 0.5 }
			else if .Right == pin { center.x -= ( value - size.width ) * 0.5 }
			size.width = value
		case .Top:
			if .Bottom == pin { size.height = bottom - value }
			else if .CenterY == pin { size.height = ( center.y - value ) * 2.0 }
			center.y = value + size.height * 0.5
		case .Bottom:
			if .Top == pin { size.height = value - top }
			else if .CenterY == pin { size.height = ( value - center.y ) * 2.0 }
			center.y = value - size.height * 0.5
		case .CenterY:
			if .Top == pin { size.height = ( value - top ) * 2.0 }
			else if .Bottom == pin { size.height = ( bottom - value ) * 2.0 }
			center.y = value
		case .Height:
			if .Top == pin { center.y += ( value - size.height ) * 0.5 }
			else if .Bottom == pin { center.y -= ( value - size.height ) * 0.5 }
			size.height = value
		}
	}
	
	/// ViewBox copy with single property changed and optionally pinning related property
	public func setting( property:Property, to value:CGFloat, pinning:Property? = nil ) -> ViewBox {
		var result = self
		result.assignProperty( property, value:value, pinning:pinning )
		return result
	}
	
	/// ViewBox copy with arbitrary properties changed and pinning previously set properties
	public func setting( propertiesToValues:[( property:Property, value:CGFloat )] ) -> ViewBox {
		var result = self
		var prior_v:Property?, prior_h:Property?
		
		for entry in propertiesToValues {
			let c = entry.property.concrete
			let p = c.isVertical ? prior_v : prior_h
			
			c.isPosition ? c.isVertical ? ( prior_v = c ) : ( prior_h = c ) : ()
			result.assignProperty( c, value:entry.value, pinning:p )
		}
		
		return result
	}
}

//	MARK: Anchor Point Accessors

public extension ViewBox {
	public enum Anchor : Int {
		case TopLeft = 5, TopRight = 6, BottomLeft = 9, BottomRight = 10,
			TopLeading = 21, TopTrailing = 22, BottomLeading = 25, BottomTrailing = 26,
			CenterLeft = 13, CenterRight = 14, CenterTop = 7, CenterBottom = 11,
			CenterLeading = 29, CenterTrailing = 30,
			Center = 15
		
		var isAbstract:Bool { return ( rawValue & 16 ) != 0 }
		var isCorner:Bool { return horizontal != .CenterX && vertical != .CenterY }
		var isCenter:Bool { return horizontal == .CenterX && vertical == .CenterY }
		var isEdge:Bool { return ( horizontal == .CenterX ) != ( vertical == .CenterY ) }
		var concrete:Anchor { return isAbstract ? Anchor( rawValue:( rawValue ^ ( UI.isRTL ? 19 : 16 ) ) )! : self }
		var opposite:Anchor? { return Anchor( rawValue:( ( rawValue & 5 ) << 1 ) | ( ( rawValue & 10 ) >> 1 ) | ( rawValue & ~15 ) ) }
		
		var unit:CGPoint {
			let r = concrete.rawValue							//	0 1 2 3
			let s = r & ~( ( (r&5) << 1 ) | ( (r&10) >> 1 ) )	//	0 1 2 0
			let t = s ^ ( (~s&10) >> 1 )						//	1 0 2 1
			
			return CGPoint( x:CGFloat( t&3 )*0.5, y:CGFloat( (t>>2)&3 )*0.5 )
		}
		
		var vertical:Property {
			switch rawValue & 12 {
			case 8: return .Bottom
			case 4: return .Top
			default: return .CenterY
			}
		}
		
		var horizontal:Property {
			switch rawValue & 3 {
			case 2: return isAbstract ? .Trailing : .Right
			case 1: return isAbstract ? .Leading : .Left
			default: return .CenterX
			}
		}
		
		init?( horizontal:Property, vertical:Property ) {
			let h:Int, v:Int
			
			switch horizontal {
			case .Left: h = 1
			case .Leading: h = 17
			case .Right: h = 2
			case .Trailing: h = 18
			case .CenterX: h = 3
			default: h = 0
			}
			
			switch vertical {
			case .Top: v = 4
			case .Bottom: v = 8
			case .CenterY: v = 12
			default: v = 0
			}
			
			if h == 0 || v == 0 { return nil }
			self = Anchor( rawValue:h | v )!
		}
	}
	
	/// ViewBox with anchor point and size
	public init( anchor:Anchor, var point x:CGFloat, var _ y:CGFloat, size w:CGFloat, _ h:CGFloat ) {
		switch anchor.horizontal.concrete {
		case .CenterX: break
		case .Right: x -= w * 0.5
		default: x += w * 0.5
		}
		
		switch anchor.vertical.concrete {
		case .CenterY: break
		case .Bottom: y -= h * 0.5
		default: y += h * 0.5
		}
		
		self.size = CGSize( width:w, height:h )
		self.center = CGPoint( x:x, y:y )
	}
	
	/// ViewBox with anchor point and size
	public init( anchor:Anchor, var point:CGPoint, size:CGSize ) {
		switch anchor.horizontal.concrete {
		case .CenterX: break
		case .Right: point.x -= size.width * 0.5
		default: point.x += size.width * 0.5
		}
		
		switch anchor.vertical.concrete {
		case .CenterY: break
		case .Bottom: point.y -= size.height * 0.5
		default: point.y += size.height * 0.5
		}
		
		self.size = size
		self.center = point
	}
	
	/// ViewBox with anchor point and opposite point
	public init( anchor:Anchor, point p:CGPoint, opposite o:CGPoint ) {
		let x, y, w, h:CGFloat
		
		switch anchor.horizontal.concrete {
		case .Left: x = p.x; w = o.x - p.x
		case .Right: x = o.x; w = p.x - o.x
		default: x = ( p.x + o.x ) * 0.5; w = fabs( p.x - o.x )
		}
		
		switch anchor.vertical.concrete {
		case .Top: y = p.y; h = o.y - p.y
		case .Bottom: y = o.y; h = p.y - o.y
		default: y = ( p.y + o.y ) * 0.5; h = fabs( p.y - o.y )
		}
		
		self.size = CGSize( width:w, height:h )
		self.center = CGPoint( x:x + w*0.5, y:y + h*0.5 )
	}
	
	/// ViewBox with anchor point and opposite point
	public init( anchor:Anchor, point px:CGFloat, _ py:CGFloat, opposite ox:CGFloat, _ oy:CGFloat ) {
		let x, y, w, h:CGFloat
		
		switch anchor.horizontal.concrete {
		case .Left: x = px; w = ox - px
		case .Right: x = ox; w = px - ox
		default: x = px; w = fabs( px - ox ) * 2.0
		}
		
		switch anchor.vertical.concrete {
		case .Top: y = py; h = oy - py
		case .Bottom: y = oy; h = py - oy
		default: y = py; h = fabs( py - oy ) * 2.0
		}
		
		self.size = CGSize( width:w, height:h )
		self.center = CGPoint( x:x + w*0.5, y:y + h*0.5 )
	}
	
	/// ViewBox anchor point
	public func anchor( anchor:Anchor ) -> CGPoint {
		return CGPoint( x:property( anchor.horizontal ), y:property( anchor.vertical ) )
	}
	
	public subscript( a:Anchor ) -> CGPoint {
		get { return anchor( a ) }
		set { move( a, to:newValue ) }
	}
	
	/// ViewBox copy with anchor point at position preserving size
	public mutating func move( anchor:Anchor, to:CGPoint ) {
		assignProperty( anchor.horizontal, value:to.x )
		assignProperty( anchor.vertical, value:to.y )
	}
	
	/// move anchor point to position preserving size
	public func moving( anchor:Anchor, to:CGPoint ) -> ViewBox {
		var result = self
		result.move( anchor, to:to )
		return result
	}
	
	/// ViewBox copy with size or position adjusted to have new anchor point
	public func with( anchor:Anchor, at:CGPoint ) -> ViewBox {
		let x, y, width, height:CGFloat
		
		switch anchor.horizontal.concrete {
		case .Left: width = self.right - at.x; x = at.x + width * 0.5
		case .Right: width = at.x - self.left; x = at.x - width * 0.5
		default: width = size.width; x = at.x
		}
		
		switch anchor.vertical.concrete {
		case .Top: height = self.bottom - at.y; y = at.y + height * 0.5
		case .Bottom: height = at.y - self.top; y = at.y - height * 0.5
		default: height = size.height; y = at.y
		}
		
		return ViewBox( center:CGPoint( x:x, y:y ), size:CGSize( width:width, height:height ) )
	}
	
	/**
		extract piece of ViewBox
		
		anchor: reference anchor for calculating position
		position (x,y): 0<(x,y)<1 is fraction, -1<(x,y)<0 is portion
		size (width, height): 0<(w,h)<1 is fraction, (w,h)<=0 is relative
	*/
	public func piece( anchor:Anchor, position x:CGFloat, _ y:CGFloat, size width:CGFloat, _ height:CGFloat ) -> ViewBox {
		let slice = size.piece( width, height )
		let h = anchor.horizontal.concrete
		let v = anchor.vertical.concrete
		let cx, cy:CGFloat
		
		if !isfinite(x) {
			switch h {
			case .Left: cx = center.x - ( size.width - slice.width ) * 0.5
			case .Right: cx = center.x + ( size.width - slice.width ) * 0.5
			default: cx = center.x
			}
		} else if -1 < x && x < 0 {
			switch h {
			case .Left: cx = center.x - ( size.width - slice.width ) * ( 0.5 + x )
			case .Right: cx = center.x + ( size.width - slice.width ) * ( 0.5 + x )
			default: cx = center.x - ( size.width - slice.width ) * ( 0.5 + x )
			}
		} else if 0 < x && x < 1 {
			switch h {
			case .Left: cx = center.x - size.width * ( 0.5 - x ) + slice.width * 0.5
			case .Right: cx = center.x + size.width * ( 0.5 - x ) - slice.width * 0.5
			default: cx = center.x - size.width * ( 0.5 - x )
			}
		} else {
			switch h {
			case .Left: cx = center.x - ( size.width - slice.width ) * 0.5 + x
			case .Right: cx = center.x + ( size.width - slice.width ) * 0.5 - x
			default: cx = center.x + x
			}
		}
		
		if !isfinite(y) {
			switch v {
			case .Top: cy = center.y - ( size.height - slice.height ) * 0.5
			case .Bottom: cy = center.y + ( size.height - slice.height ) * 0.5
			default: cy = center.y
			}
		} else if -1 < y && y < 0 {
			switch v {
			case .Top: cy = center.y - ( size.height - slice.height ) * ( 0.5 + y )
			case .Bottom: cy = center.y + ( size.height - slice.height ) * ( 0.5 + y )
			default: cy = center.y - ( size.height - slice.height ) * ( 0.5 + y )
			}
		} else if 0 < y && y < 1 {
			switch v {
			case .Top: cy = center.y - size.height * ( 0.5 - y ) + slice.height * 0.5
			case .Bottom: cy = center.y + size.height * ( 0.5 - y ) - slice.height * 0.5
			default: cy = center.y - size.height * ( 0.5 - y )
			}
		} else {
			switch v {
			case .Top: cy = center.y - ( size.height - slice.height ) * 0.5 + y
			case .Bottom: cy = center.y + ( size.height - slice.height ) * 0.5 - y
			default: cy = center.y + y
			}
		}
		
		return ViewBox( center:CGPoint( x:cx, y:cy ) , size:slice )
	}
}

//	MARK: ViewBox Screen

public extension ViewBox {
	public static func screenBounds() -> CGRect {
		if #available(iOS 8.0, *) {
			return UIScreen.mainScreen().nativeBounds
		} else {
			return UIScreen.mainScreen().bounds
		}
	}
	
	public static let screenBox = ViewBox( origin:CGPoint(), size:ViewBox.screenBounds().size )
	public static var screenScale = UIScreen.mainScreen().scale
	
	public enum Unit : Int {
		case Point, Pixel, Percent, ScreenArea
		
		var toPoint:CGFloat {
			switch self {
			case .Point: return 1
			case .Pixel: return ViewBox.screenScale
			case .Percent: return ViewBox.screenBox.width / 100
			case .ScreenArea: return ViewBox.screenBox.height / 480
			}
		}
		
		func conversion( unit:Unit ) -> CGFloat { return unit.toPoint / toPoint }
		func convert( value:CGFloat, to:Unit ) -> CGFloat { return value * conversion(to) }
		func convert( point:CGPoint, to:Unit ) -> CGPoint { return point * conversion(to) }
		func convert( size:CGSize, to:Unit ) -> CGSize { return size * conversion(to) }
	}
	
	func convert( from:Unit, to:Unit ) -> ViewBox {
		guard from != to else { return self }
		
		let conversion = from.conversion( to )
		let converted = ViewBox( center:center * conversion, size:size * conversion )
		
		return to == .Point ? converted.interface : converted
	}
}

//	MARK: -

public extension UIView {
	///	ViewBox to use when positioning views
	public var box:ViewBox {
		get { return ViewBox( frame:alignmentRectForFrame( frame ) ) }
		set {
			let natural = frameForAlignmentRect( newValue.interfaceFrame )
			if !frame.size.isNear( natural.size ) { frame = natural }
			else if !center.isNear( natural.center ) { center = natural.center }
		}
	}
	
	///	ViewBox as view frame without layout adjustemnts
	public var frameBox:ViewBox {
		get { return ViewBox( frame:frame ) }
		set {
			if !frame.size.isNear( newValue.size ) { frame = newValue.frame }
			else if !center.isNear( newValue.center ) { center = newValue.center }
		}
	}
	
	///	ViewBox to use when positioning subviews
	public var boundingBox:ViewBox {
		get { let s = bounds.size; return ViewBox( center:s.centerPoint, size:s ) }
	}
	
	///	ViewBox with current center and intrinsic content size
	public var intrinsicBox:ViewBox {
		get { return ViewBox( center:center, size:intrinsicContentSize() ) }
	}
	
	///	ViewBox with size fitting given dimensions
	public func boxFittingSize( width:CGFloat, _ height:CGFloat ) -> ViewBox {
		let fits:CGSize
		let size:CGSize
		
		if width < 0 && height < 0 {
			size = CGSize( width:-width, height:-height )
		} else {
			fits = sizeThatFits( CGSize( width:fabs( width ), height:fabs( height ) ) )
			size = CGSize( width:( width < 0 ? -width : fits.width ), height:( height < 0 ? -height : fits.height ) )
		}
		
		return ViewBox( center:center, size:size )
	}
}

//	MARK: -

public struct UI {
	public static var isRTL:Bool { return UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft }
	public static var locale = NSLocale.autoupdatingCurrentLocale()
	
	public static var tolerance:CGFloat = 1.0/256.0
}

//	MARK: -

public extension NSLocale {
	public var isRTL:Bool { return NSLocale.characterDirectionForLanguage( objectForKey( NSLocaleLanguageCode ) as! String ) == .RightToLeft }
}

//	MARK: -

public extension CGSize {
	public init( square:CGFloat ) { width = square; height = square }
	public init( point:CGPoint ) { width = point.x; height = point.y }
	
	/// true if both with and height are positive
	public var isPositive:Bool { return width > 0 && height > 0 }
	
	/// lesser of width and height
	public var minimum:CGFloat { return min( width, height ) }
	
	/// greater of width and height
	public var maximum:CGFloat { return max( width, height ) }
	
	/// round width and height up to integer values
	public var integral:CGSize { return CGSize( width:ceil(width-UI.tolerance), height:ceil(height-UI.tolerance) ) }
	
	/// round width and height up to even integer values
	public var evenSize:CGSize { return CGSize( width:ceil(width*0.5)*2.0, height:ceil(height*0.5)*2.0 ) }
	
	/// CGPoint positioned as width and height
	public var asPoint:CGPoint { return CGPoint( x:width, y:height ) }
	
	/// CGPoint at center of size with zero origin
	public var centerPoint:CGPoint { return CGPoint( x:width*0.5, y:height*0.5 ) }
	
	/// true if sizes are nearly identical within tolerance
	public func isNear( s:CGSize, tolerance:CGFloat = UI.tolerance ) -> Bool {
		return !( fabs( s.width - width ) > tolerance || fabs( s.height - height ) > tolerance )
	}
	
	/// fractional or relative sized piece of size
	public func piece( w:CGFloat, _ h:CGFloat ) -> CGSize {
		return CGSize(
			width:( isfinite( w ) ? w > 0.0 ? w < 1.0 ? width * w : w : width + w : width ),
			height:( isfinite( h ) ? h > 0.0 ? h < 1.0 ? height * h : h : height + h : height )
		)
	}
}

//	MARK: -

public extension CGPoint {
	/// CGPoint copy rounded to integer coordinates
	public var integral:CGPoint { return CGPoint( x:round(x), y:round(y) ) }
	
	/// true if points are nearly identical within tolerance
	public func isNear( p:CGPoint, tolerance:CGFloat = UI.tolerance ) -> Bool { return !( fabs( p.x - x ) > tolerance || fabs( p.y - y ) > tolerance ) }
	
	/// CGPoint copy advanced in interface direction
	public func advance( x forward:CGFloat, y down:CGFloat = 0 ) -> CGPoint { return CGPoint( x:self.x + ( UI.isRTL ? -forward : forward ), y:self.y + down ) }
	
	/// CGPoint copy offset in coordinate space
	public func offset( x right:CGFloat, y down:CGFloat = 0 ) -> CGPoint { return CGPoint( x:self.x + right, y:self.y + down ) }
	
	/// CGPoint copy offset up
	public func up( y:CGFloat ) -> CGPoint { return CGPoint( x:self.x, y:self.y - y ) }
	
	/// CGPoint copy offset down
	public func down( y:CGFloat ) -> CGPoint { return CGPoint( x:self.x, y:self.y + y ) }
	
	/// CGPoint such that size would have integer origin when centered at result
	public func interfaceCenterForSize( size:CGSize ) -> CGPoint {
		return CGPoint( x:( size.width % 2.0 == 1.0 ? round(x*2.0)*0.5 : round(x) ), y:( size.height % 2.0 == 1.0 ? round(y*2.0)*0.5 : round(y) ) )
	}
	
	/// angle of point as vector rotated from horizontal axis
	public var angle:Double { return atan2( Double(y), Double(x) ) }
}

//	MARK: -

public extension CGRect {
	public init( origin x:CGFloat, _ y:CGFloat, size width:CGFloat, _ height:CGFloat ) { origin = CGPoint( x:x, y:y ); size = CGSize( width:width, height:height ) }
	public init( size s:CGSize ) { size = s; origin = CGPoint() }
	public init( center c:CGPoint, size s:CGSize ) { size = s; origin = CGPoint( x:(c.x - s.width * 0.5), y:(c.y - s.height * 0.5) ) }
	
	/// CGRect copy with even size and interger origin
	public var evenFrame:CGRect { return CGRect( center:center.integral, size:size.evenSize ) }
	
	/// CGRect with integer size and origin
	public var interfaceFrame:CGRect { let s = size.integral; return CGRect( center:center.interfaceCenterForSize(s), size:s ) }
	public var isPositive:Bool { return size.isPositive }
	
	/// CGPoint center of rectangle
	public var center:CGPoint {
		get { return CGPoint( x:origin.x + size.width * 0.5, y:origin.y + size.height * 0.5 ) }
		set { origin = CGPoint( x:newValue.x - size.width * 0.5, y:newValue.y - size.height * 0.5 ) }
	}
}

//	MARK: -

public func * ( size:CGSize, scalar:CGFloat ) -> CGSize { return CGSize( width:size.width * scalar, height:size.height * scalar ) }
public func * ( point:CGPoint, scalar:CGFloat ) -> CGPoint { return CGPoint( x:point.x * scalar, y:point.y * scalar ) }

public func + ( size:CGSize, adjust:CGSize ) -> CGSize { return CGSize( width:size.width + adjust.width, height:size.height + adjust.height ) }
public func - ( size:CGSize, adjust:CGSize ) -> CGSize { return CGSize( width:size.width - adjust.width, height:size.height - adjust.height ) }
public func * ( size:CGSize, adjust:CGSize ) -> CGSize { return CGSize( width:size.width * adjust.width, height:size.height * adjust.height ) }
public func / ( size:CGSize, adjust:CGSize ) -> CGSize { return CGSize( width:size.width / adjust.width, height:size.height / adjust.height ) }

public func >> ( point:CGPoint, scalar:CGFloat ) -> CGPoint { return point.advance( x:scalar ) }
public func >> ( point:CGPoint, offset:(x:CGFloat, y:CGFloat) ) -> CGPoint { return point.advance( x:offset.x, y:offset.y ) }
public func << ( point:CGPoint, scalar:CGFloat ) -> CGPoint { return point.advance( x:-scalar ) }
public func << ( point:CGPoint, offset:(x:CGFloat, y:CGFloat) ) -> CGPoint { return point.advance( x:-offset.x, y:offset.y ) }

public func | ( origin:CGPoint, size:CGSize ) -> CGRect { return CGRect( origin:origin, size:size ) }
public func | ( frame:CGRect, other:CGRect ) -> CGRect { return CGRectUnion( frame, other ) }
public func & ( frame:CGRect, other:CGRect ) -> CGRect { return CGRectIntersection( frame, other ) }
public func && ( frame:CGRect, other:CGRect ) -> Bool { return CGRectIntersectsRect( frame, other ) }

//	MARK: -

public func + ( box:ViewBox, offset:CGPoint ) -> ViewBox { return box.offset( offset.x, offset.y ) }
public func - ( box:ViewBox, offset:CGPoint ) -> ViewBox { return box.offset( -offset.x, -offset.y ) }
public func + ( box:ViewBox, adjust:CGSize ) -> ViewBox { return ViewBox( center:box.center, size:box.size + adjust ) }
public func - ( box:ViewBox, adjust:CGSize ) -> ViewBox { return ViewBox( center:box.center, size:box.size - adjust ) }
public func >> ( box:ViewBox, amount:CGFloat ) -> ViewBox { return box.advance( amount ) }
public func >> ( box:ViewBox, amount:(x:CGFloat, y:CGFloat) ) -> ViewBox { return box.advance( amount.x, amount.y ) }
public func << ( box:ViewBox, amount:CGFloat ) -> ViewBox { return box.advance( -amount ) }
public func << ( box:ViewBox, amount:(x:CGFloat, y:CGFloat) ) -> ViewBox { return box.advance( -amount.x, -amount.y ) }

public func ^ ( center:CGPoint, size:CGSize ) -> ViewBox { return ViewBox( center:center, size:size ) }
public func | ( frame:ViewBox, other:ViewBox ) -> ViewBox { return frame.union( other ) }
public func & ( frame:ViewBox, other:ViewBox ) -> ViewBox { return frame.intersect( other ) }
public func && ( frame:ViewBox, other:ViewBox ) -> Bool { return frame.intersects( other ) }

extension ViewBox : Equatable {}

public func == ( lhs:ViewBox, rhs:ViewBox ) -> Bool { return lhs.isNear( rhs, tolerance:0 ) }
public func ~= ( lhs:ViewBox, rhs:ViewBox ) -> Bool { return lhs.isNear( rhs ) }
