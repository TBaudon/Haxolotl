package haxolotl.core.render;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxolotl.core.TextureRegion;
import haxolotl.display.DisplayObject;
import haxolotl.utils.Color;

/**
 * ...
 * @author Thomas B
 */
class CanvasDrawer
{
	
	var m_buffer : BitmapData;
	var m_region : Rectangle;
	var m_colorRegion : Rectangle;
	var m_transform : Matrix;
	var m_colorTransform : ColorTransform;
	var m_data : BitmapData;
	var m_dest : Point;
	var m_col : Color;
	
	var m_tintCache : Map < Rectangle, Map < Int, BitmapData >> ;

	public function new(buffer : BitmapData) 
	{
		m_buffer = buffer;
		m_dest = new Point();
		m_colorTransform = new ColorTransform();
		m_tintCache = new Map < Rectangle, Map < Int, BitmapData >> () ;
		m_col = new Color(0xffffff);
		m_colorRegion = new Rectangle(0, 0, 1, 1);
		m_transform = new Matrix();
	}
	
	public function render(object : DisplayObject)
	{
		if (object.texture != null)
		{
			m_dest.x = 0;
			m_dest.y = 0;
			m_region = object.texture.region;
			m_data = object.texture.texture.bitmapData;
			
			m_transform = object.transform;

			m_transform.tx = Math.round(m_transform.tx);
			m_transform.ty = Math.round(m_transform.ty);
			
			if (object.color != 0xFFFFFF)
			{
				
				m_col.set(object.color);
				m_colorTransform.redMultiplier = m_col.r;
				m_colorTransform.greenMultiplier = m_col.g;
				m_colorTransform.blueMultiplier = m_col.b;
				
				var colorMap : Map<Int, BitmapData>;
				
				if (m_tintCache[m_region] == null)
				{
					colorMap = new Map<Int, BitmapData>();
					m_tintCache[m_region] = colorMap;
				}
				
				colorMap = m_tintCache[m_region];
				
				if (colorMap[object.color] == null)
				{
					var data = new BitmapData(cast m_region.width, cast m_region.height);
					data.copyPixels(m_data, m_region, m_dest);
					m_colorRegion.width = m_region.width;
					m_colorRegion.height = m_region.height;
					m_region = m_colorRegion;
					data.colorTransform(m_region, m_colorTransform);
					colorMap[object.color] = data;
				}
				
				m_colorRegion.width = m_region.width;
				m_colorRegion.height = m_region.height;
				m_region = m_colorRegion;
				m_data = colorMap[object.color];
			}
			
			// TODO : Color transform.
			// canvas doesn't allow to drawImage with color parameter, forcing us to 
			// create a colored copy of the source image. very expensive in term of memory,
			// so image tinting is just disabled at the moment as the game we need to do are 
			// quite simple and we can find work around atm.
			if (object.scaleX == 1 && object.scaleY == 1 && object.rotation == 0)
			{
				m_dest.x = m_transform.tx;
				m_dest.y = m_transform.ty;
				m_buffer.copyPixels(m_data, m_region, m_dest);
			}
			else
				m_buffer.draw(m_data, m_transform, null, null, m_region, object.smooth);
		}
		
		if (object.children != null)
			for (child in object.children)
				render(child);
	}
	
}