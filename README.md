[![Stories in Ready](https://badge.waffle.io/tbaudon/haxolotl.png?label=ready)](https://waffle.io/tbaudon/haxolotl)
#Haxolotl

**Current version**: 0.8.1

A simple game toolkit based on FLash API initialy created for learning purpose during the 28 th [**_Ludum Dare_**](http://www.ludumdare.com).
The lib aims to offer a good crossplatform alternative to FLash by using webGL on browser and OpenGL on native app.
At the moment the tool works on most decent browsers, windows, mac and android. Linux haven't been tested yet, but it should be fine on this platform as well.

To achieve this versatility accross platform, Haxolotl is build on top of [**OpenFL**][OpenFL], a great [**Haxe**](http://www.haxe.org) lib wich offers all the tool for building haxe app on several plateforms.
Soon the engine will be implemented over [**Lime**][Lime] instead of [**OpenFL**][OpenFL] to get rid of all unused flash package for the flash target.

[OpenFL]: https://github.com/openfl/openfl
[Lime]: https://github.com/openfl/lime

###Features

- crossplatform
- hardware accelerated 2d rendering
- font rendering
- flash style api
- sprite batch
- texture atlas
- basic animation

###In progress 

- multithreaded game loop (workers / Threads)
- texts
- textformat
- css style text styling 
- optimisation

###RoadMap

- particle system
- better animation handling
- google analitycs
- social integration
- migration to lime
- canvas backend for iOs (c'mon Apple :( )
- 3d rendering 
- shader tool (graphic programming)
- translation tool
- entity / system

###Install 

	haxelib git haxolotl [the Haxolotl's repo url]

###How to use 

firstly, create an openFL project.
Then in the addedToStage handler write :

	function onAddedToStage(e : Event)
	{
		var engine = new Engine(stage);
		var sampleStage = new haxolotl.core.Stage();
		engine.add(sampleStage);
		
		var atlas = new TextureAtlas(Texture.get("myAtlas.png"), "myAtlas.xml");
		
		var bunny = new Image(atlas.get("bunny"));
		
		sampleStage.add(bunny);
	}


see more in samples.