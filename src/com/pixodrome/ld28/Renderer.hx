package src.com.pixodrome.ld28;

import com.pixodrome.ld28.Mesh;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.Lib;
import openfl.display.OpenGLView;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;

import openfl.utils.Float32Array;

import flash.geom.Matrix3D;

/**
 * ...
 * @author Thomas B
 */
class Renderer
{
	
	public var view : OpenGLView;
	
	var shaderProgram : GLProgram;
	
	var vertexPosAttribute:Int;

	var meshes : Array<Mesh>;
	var vertexBuffer : GLBuffer;
	
	var angle : Float;
	
	static inline var vertexShaderSource = "
		attribute vec3 vertexPosition;
		attribute vec4 vertexColor;
			
		uniform mat4 modelViewMatrix;
		uniform mat4 projectionMatrix;
			
		void main(void) {
			gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
		}
	";
	
	static inline var fragmentShaderSource = "
		void main(void) {
			gl_FragColor = vec4(1.0,0.0,0.0,1.0);
		}
	";

	public function new() 
	{
		meshes = new Array<Mesh>();

		view = new OpenGLView();
		view.render = render;
		
		angle = 0;
		
		initShaders();
	}
	
	public function addMesh(mesh : Mesh) : Void
	{
		meshes.push(mesh);
	}
	
	function initShaders()
	{
		var vertexShader = createVertexShader();
		var fragmentShader = createFragmentShader();
		
		shaderProgram = GL.createProgram();
		
		GL.attachShader(shaderProgram, vertexShader);
		GL.attachShader(shaderProgram, fragmentShader);
		GL.linkProgram(shaderProgram);
		
		if (GL.getProgramParameter (shaderProgram, GL.LINK_STATUS) == 0)
			throw "Unable to initialize the shader program.";
		
		vertexPosAttribute = GL.getAttribLocation (shaderProgram, "vertexPosition");
	}
	
	/**
	 * Generate vertex shader
	 * @TODO try using HXSL for shader 
	 */
	function createVertexShader() : GLShader
	{
		var vertexShader = GL.createShader(GL.VERTEX_SHADER);
		GL.shaderSource(vertexShader, vertexShaderSource);
		GL.compileShader (vertexShader);
		
		if (GL.getShaderParameter (vertexShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling vertex shader";
		
		return vertexShader;
	}
	
	/**
	 * Fragment Shader
	 */
	function createFragmentShader() : GLShader
	{
		var fragmentShader = GL.createShader (GL.FRAGMENT_SHADER);
		
		GL.shaderSource (fragmentShader, fragmentShaderSource);
		GL.compileShader (fragmentShader);
		
		if (GL.getShaderParameter (fragmentShader, GL.COMPILE_STATUS) == 0)
			throw "Error compiling fragment shader";
		
		return fragmentShader;
	}
	
	function render(viewport : Rectangle) : Void
	{
		GL.viewport (Std.int (viewport.x), Std.int (viewport.y), Std.int (viewport.width), Std.int (viewport.height));
		GL.clearColor (0.0, 0.0, 0.0, 1.0);
		GL.clear (GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
		
		GL.useProgram(shaderProgram);
		GL.enableVertexAttribArray(vertexPosAttribute);
		
		for (i in 0 ... meshes.length)
			draw(meshes[i]);
		
		GL.disableVertexAttribArray(vertexPosAttribute);
		GL.useProgram(null);
	}
	
	function draw(mesh : Mesh) : Void
	{
		GL.bindBuffer (GL.ARRAY_BUFFER, mesh.getBuffer());
		GL.vertexAttribPointer (vertexPosAttribute, 3, GL.FLOAT, false, 0, 0);
		
		var projectionMatrix = Matrix3D.createOrtho (0, 800, 480, 0, 1000, -1000);
		var modelViewMatrix = Matrix3D.create2D (0, 0, 1, angle);
		
		var projectionMatrixUniform = GL.getUniformLocation (shaderProgram, "projectionMatrix");
		var modelViewMatrixUniform = GL.getUniformLocation (shaderProgram, "modelViewMatrix");
			
		GL.uniformMatrix3D (projectionMatrixUniform, false, projectionMatrix);
		GL.uniformMatrix3D (modelViewMatrixUniform, false, modelViewMatrix);
			
		GL.drawArrays (GL.TRIANGLES, 0, cast(mesh.vertices.length / 3));
			
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
	}
	
}