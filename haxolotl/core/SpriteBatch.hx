package haxolotl.core;

import flash.geom.Matrix;
import flash.geom.Matrix3D;
import haxolotl.geom.Rectangle;
import haxolotl.display.DisplayObject;
import haxolotl.shaders.SpriteBatchShader;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;
import openfl.utils.Int16Array;

/**
 * ...
 * @author Thomas B
 */
class SpriteBatch implements IDrawable
{
	var texture : Texture;
	
	var first : DisplayObject;
	var last : DisplayObject;
	
	var vertex : Float32Array;
	var index : Int16Array;
	
	var vertexBuffer : GLBuffer;
	var indexBuffer : GLBuffer;
	
	var projectionUniform : GLUniformLocation;
	var textureUniform : GLUniformLocation;
	
	var vertexPosAttribute : Int;
	var texCoordAttribute : Int;
	var colorAttribute : Int;
	
	var program : Program;
	var projectionMatrix:Matrix3D;
	
	var needGeneration : Bool;
	
	var dataPerVertex : Int = 6;
	var stride : Int;
	
	var nbSprite : Int = 0;
	
	// update loop var
	
	var x1 : Float;
	var x2 : Float;
	var y1 : Float;
	var y2 : Float;
		
	var u1 : Float;
	var u2 : Float;
	var v1 : Float;
	var v2 : Float;
	
	var current:DisplayObject;
	
	var mat : Matrix;
	
	var i:Int;
	var j:Int;
	var k:Int;
	
	var t : Matrix;
	
	public var next : SpriteBatch;
	public var prev : SpriteBatch;
	
	public var full : Bool;
	public var empty : Bool;
	
	private static inline var MAX_SPRITE : Int = 16383;
	
	var tRegion : Rectangle;
	var indexes:Array<Int>;
	var nbDrawCall : Int;
	
	public function new() 
	{
		stride = dataPerVertex * 4;
		
		vertexBuffer = GL.createBuffer();
		indexBuffer = GL.createBuffer();
		
		program = new SpriteBatchShader();
		
		vertex = new Float32Array(dataPerVertex * 4 * MAX_SPRITE);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferData(GL.ARRAY_BUFFER, vertex, GL.DYNAMIC_DRAW);
		
		index = new Int16Array(MAX_SPRITE * 6);
		indexes = [0, 1, 2, 2, 3, 0];
		
		var j : Int = 0;
		var k : Int = 0;
		
		// Fill the index buffer as it never need to change
		for (i in 0 ... MAX_SPRITE)
		{
			for (a in indexes)
				index[j++] = a + k * 4;
			k++;
		}
			
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, index, GL.STATIC_DRAW);
		
		full = false;
		empty = true;
		
		program.use();
		
		initUniforms();
		initAttributes();
	}
	
	function initUniforms() 
	{
		projectionUniform = GL.getUniformLocation(program.program, "projectionMatrix");
		textureUniform = GL.getUniformLocation(program.program, "uImage0");
	}
	
	function initAttributes()
	{
		vertexPosAttribute = GL.getAttribLocation(program.program, "aVertPos");
		texCoordAttribute = GL.getAttribLocation(program.program, "aTexCoord");
		colorAttribute = GL.getAttribLocation(program.program, "aColor");
	}
	
	public function setProjectionMatrix(projection : Matrix3D) : Void
	{
		projectionMatrix = projection;
	}
	
	public function start()
	{
		i = 0;
		j = 0;
		k = 0;
		tRegion = null;
		nbDrawCall = 0;
	}
	
	public function render(object : DisplayObject)
	{
		if (object.texture != null)
		{
			if (object.texture.texture != texture)
			{
				flush();
				texture = object.texture.texture;
			}
			
			t = object.transform;
			
			x1 = 0;
			x2 = object.baseWidth;
			y1 = 0;
			y2 = object.baseHeight;
				
			u1 = 0.0;
			v1 = 0.0;
			u2 = 1.0;
			v2 = 1.0;
			
			if(object.texture != null)
				tRegion = object.texture.region;
			
			if (tRegion != null)
			{
				u1 = tRegion.x;
				v1 = tRegion.y;
				u2 = tRegion.x + tRegion.width;
				v2 = tRegion.y + tRegion.height;
			}
			
			// top left
			vertex[i++] = x1 * t.a + y1 * t.c + t.tx;
			vertex[i++] = x1 * t.b + y1 * t.d + t.ty;
			vertex[i++] = u1;
			vertex[i++] = v1;
			vertex[i++] = object.alpha;
			vertex[i++] = object.color;
			
			// top right
			vertex[i++] = x2 * t.a + y1 * t.c + t.tx;
			vertex[i++] = x2 * t.b + y1 * t.d + t.ty;
			vertex[i++] = u2;
			vertex[i++] = v1;
			vertex[i++] = object.alpha;
			vertex[i++] = object.color;
			
			// bottom right
			vertex[i++] = x2 * t.a + y2 * t.c + t.tx;
			vertex[i++] = x2 * t.b + y2 * t.d + t.ty;
			vertex[i++] = u2;
			vertex[i++] = v2;
			vertex[i++] = object.alpha;
			vertex[i++] = object.color;
			
			// bottom left
			vertex[i++] = x1 * t.a + y2 * t.c + t.tx;
			vertex[i++] = x1 * t.b + y2 * t.d + t.ty;
			vertex[i++] = u1;
			vertex[i++] = v2;
			vertex[i++] = object.alpha;
			vertex[i++] = object.color;
			
			for (a in indexes)
				index[j++] = a + k * 4;
			
			k++;
		}
		
		if (object.children != null && object.children.length > 0)
			for (child in object.children)
				render(child);
	}
	
	public function end()
	{
		flush();
	}
	
	public function update()
	{
		current = first;
		
		i = 0;
		j = 0;
		k = 0;
		
		while (current != null)
		{
			
			t = current.transform;
			
			x1 = 0;
			x2 = current.baseWidth;
			y1 = 0;
			y2 = current.baseHeight;
				
			u1 = 0.0;
			v1 = 0.0;
			u2 = 1.0;
			v2 = 1.0;
			
			tRegion = current.texture.region;
			
			if (tRegion != null)
			{
				u1 = tRegion.x;
				v1 = tRegion.y;
				u2 = tRegion.x + tRegion.width;
				v2 = tRegion.y + tRegion.height;
			}
			
			// top left
			vertex[i++] = x1 * t.a + y1 * t.c + t.tx;
			vertex[i++] = x1 * t.b + y1 * t.d + t.ty;
			vertex[i++] = u1;
			vertex[i++] = v1;
			vertex[i++] = current.alpha;
			vertex[i++] = current.color;
			
			// top right
			vertex[i++] = x2 * t.a + y1 * t.c + t.tx;
			vertex[i++] = x2 * t.b + y1 * t.d + t.ty;
			vertex[i++] = u2;
			vertex[i++] = v1;
			vertex[i++] = current.alpha;
			vertex[i++] = current.color;
			
			// bottom right
			vertex[i++] = x2 * t.a + y2 * t.c + t.tx;
			vertex[i++] = x2 * t.b + y2 * t.d + t.ty;
			vertex[i++] = u2;
			vertex[i++] = v2;
			vertex[i++] = current.alpha;
			vertex[i++] = current.color;
			
			// bottom left
			vertex[i++] = x1 * t.a + y2 * t.c + t.tx;
			vertex[i++] = x1 * t.b + y2 * t.d + t.ty;
			vertex[i++] = u1;
			vertex[i++] = v2;
			vertex[i++] = current.alpha;
			vertex[i++] = current.color;
			
			for (a in indexes)
				index[j++] = a + k * 4;
			
			k++;
			
			current = current.next;
		}
			
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, vertex);
	}
	
	private function flush()
	{
		nbDrawCall++;
	}
	
	public function draw()
	{
		initDraw();
		GL.drawElements(GL.TRIANGLES, nbSprite * 6, GL.UNSIGNED_SHORT, 0);
		endDraw();
	}
	
	function initDraw() 
	{
		update();
		
		#if desktop
		GL.enable(GL.TEXTURE_2D);
		#end
		
		program.use();
		
		GL.enable(GL.BLEND);
		GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
		GL.disable(GL.DEPTH_TEST);
		
		GL.uniformMatrix3D(projectionUniform, false, projectionMatrix);
		GL.uniform1i(textureUniform, 0);
		
		GL.bindTexture(GL.TEXTURE_2D, texture.texture);
		GL.activeTexture(GL.TEXTURE0);
		
		GL.enableVertexAttribArray(vertexPosAttribute);
		GL.enableVertexAttribArray(texCoordAttribute);
		GL.enableVertexAttribArray(colorAttribute);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
		
		GL.vertexAttribPointer(vertexPosAttribute, 2, GL.FLOAT, false, stride, 0);
		GL.vertexAttribPointer(texCoordAttribute, 2, GL.FLOAT, false, stride, 2 * 4);
		GL.vertexAttribPointer(colorAttribute, 2, GL.FLOAT, false, stride, 4 * 4);
	}
	
	function endDraw() 
	{
		program.release();
		
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		GL.bindTexture(GL.TEXTURE_2D, null);
		
		GL.disable(GL.BLEND);
		
		GL.disableVertexAttribArray(vertexPosAttribute);
		GL.disableVertexAttribArray(texCoordAttribute);
		GL.disableVertexAttribArray(colorAttribute);
		
		#if desktop
		GL.disable(GL.TEXTURE_2D);
		#end
	}
}