package com.pixodrome.ld28;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import openfl.gl.GLUniformLocation;
import openfl.gl.GL;

/**
 * ...
 * @author Thomas BAUDON
 */
class Model implements IDrawable
{
	public var program : Program;
	
	public var position : Vector3D;
	public var rotation : Vector3D;
	public var scale : Vector3D;
	
	var mesh : Mesh;
	var texture : Texture;
	var transform : Matrix3D;
	
	var vtxPosAttr : Int;
	var texCoordAttr : Int;
	
	var imageUniform : GLUniformLocation;

	public function new(_mesh : Mesh, _texture : Texture, _program : Program = null) 
	{
		mesh = _mesh;
		texture = _texture;
		transform = new Matrix3D();
		
		position = new Vector3D();
		rotation = new Vector3D();
		
		scale = new Vector3D(1, 1, 1);
		
		if (_program == null)
			_program = new Program("basic");
		program = _program;
		
		GL.useProgram(program.program);
		initAttributes();
		initUniforms();
	}
	
	function initAttributes() 
	{
		vtxPosAttr = GL.getAttribLocation(program.program, "vertexPosition");
		texCoordAttr = GL.getAttribLocation(program.program, "aTexCoord");
	}
	
	function initUniforms() 
	{
		imageUniform = GL.getUniformLocation(program.program, "uImage0");
	}
	
	public function draw(renderer : Renderer)
	{
		updateMatrix();
		
		GL.useProgram(program.program);
		GL.enableVertexAttribArray(vtxPosAttr);
		GL.enableVertexAttribArray(texCoordAttr);
		
		var projectionMatrixUniform = GL.getUniformLocation(program.program, "projectionMatrix");
		var modelViewMatrixUniform = GL.getUniformLocation(program.program, "modelViewMatrix");
	
		GL.uniformMatrix3D(projectionMatrixUniform, false, renderer.projectionMatrix);
		GL.uniformMatrix3D(modelViewMatrixUniform, false, transform);
		GL.uniform1i(imageUniform, 0);
		
		GL.activeTexture(GL.TEXTURE0);
		GL.bindTexture(GL.TEXTURE_2D, texture.texture);
		
		GL.bindBuffer (GL.ARRAY_BUFFER, mesh.getBuffer());
		GL.vertexAttribPointer (vtxPosAttr, 3, GL.FLOAT, false, 0, 0);
		
		GL.bindBuffer (GL.ARRAY_BUFFER, mesh.getTextCoord());
		GL.vertexAttribPointer (texCoordAttr, 2, GL.FLOAT, false, 0, 0);
			
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, mesh.getIndexBuffer());
		
		GL.drawElements(GL.TRIANGLES, mesh.indexes.length, GL.UNSIGNED_SHORT, 0);
	}
	
	function updateMatrix() 
	{
		transform.identity();
		
		transform.appendRotation(rotation.w, rotation);
		transform.position = position;
	}
	
}