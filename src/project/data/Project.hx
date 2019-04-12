package project.data;

import modules.entities.EntityTemplateList;
import js.node.Path;

class Project
{
	public var name:String;
	public var levelPaths:Array<String> = [ '.' ];
	public var backgroundColor:Color = Color.fromHex("#282c34", 1);
	public var gridColor:Color = Color.fromHex("#3c4049", 0.8);
	public var anglesRadians:Bool = true;
	public var defaultExportMode:String = ".xml"; // TODO het lets change this -01010111

	public var levelDefaultSize:Vector = new Vector(320, 240);
	public var levelMinSize:Vector = new Vector(128, 128);
	public var levelMaxSize:Vector = new Vector(4096, 4096);
	public var levelValues:Array<ValueTemplate> = [];

	public var entities:EntityTemplateList = new EntityTemplateList();
	public var layers:Array<LayerTemplate> = [];
	public var tilesets:Array<Tileset> = [];

	//Not exported
	public var path:String;
	public var lastSavePath:String;
	public var _nextUnsavedLevelID:Int = 0;

	public function new(path:String)
	{
		this.name = "New Project";
		this.path = Path.resolve(path);
	}
	
	public function unload()
	{
		for (layer in layers) layer.projectWasLoaded(this);
		for (tileset in tilesets) tileset.texture.dispose();
	}

	public function getEntityTemplate(id:Int):EntityTemplate
	{
		if (id >= 0 && id < entities.templates.length) return entities.templates[id];
		return null;
	}

	public function getEntityTemplateByExportID(exportID:String): EntityTemplate
	{
		for (entity in entities) if (entity.exportID == exportID) return entity;
		return null;
	}
	
	public function getTileset(name:String):Tileset
	{
		for (tileset in tilesets) if (tileset.label == name) return tileset;
		if (tilesets.length > 0) return tilesets[0];

		throw "No tilesets in the project!";
	}

	public function getNextLayerTemplateExportID():String
	{
		return (new Date().getTime()).toString(36).substring(4, 8) + Math.random().toString(36).substring(2, 6);
	}

	public function getNextEntityTemplateExportID():String
	{
		return (new Date().getTime()).toString(36).substring(4, 8) + Math.random().toString(36).substring(2, 6);
	}

	public function getNextUnsavedLevelID():Float
	{
		return _nextUnsavedLevelID++;
	}

	/*
			LEVEL PATHS
	*/

	public function getAbsoluteLevelPath(path:String):String
	{
		return Path.resolve(Path.dirname(this.path), path);
	}

	public function getRelativeLevelPath(path:String):String
	{
		return Path.relative(Path.dirname(this.path), path);
	}

	public function getAbsoluteLevelDirectories():Array<String>
	{
		return [for (levelPath in levelPaths) getAbsoluteLevelPath(levelPath)];
	}

	public function getAbsoluteLevelPathIndex(path:String):Int
	{
		return getAbsoluteLevelDirectories().indexOf(path);
	}

	public function removeAbsoluteLevelPathAndSave(path:String)
	{
		var n = getAbsoluteLevelPathIndex(path);
		if (n == -1) return;
		levelPaths.splice(n, 1);
		Export.project(this, this.path);
	}

	public function renameAbsoluteLevelPathAndSave(path:String, renameTo:String)
	{
		var n = getAbsoluteLevelPathIndex(path);
		if (n == -1) return;
		levelPaths.splice(n, 1);
		levelPaths.insert(n, getRelativeLevelPath(renameTo));
		Export.project(this, this.path);
	}

	public function initLastSavePath()
	{
		lastSavePath = getAbsoluteLevelPath(levelPaths[0]);
	}

	/*
			SAVE AND LOAD
	*/

	public function load(data:ProjectSaveFile):Project
	{
		name = data.name;
		levelPaths = data.levelPaths;
		backgroundColor = Color.fromHexAlpha(data.backgroundColor);
		gridColor = Color.fromHexAlpha(data.gridColor);
		anglesRadians = data.anglesRadians;
		levelDefaultSize = Vector.load(data.levelDefaultSize);
		levelMinSize = Vector.load(data.levelMinSize);
		levelMaxSize = Vector.load(data.levelMaxSize);
		levelValues = ValueTemplate.loadList(data.levelValues);
		defaultExportMode = Import.string(data.defaultExportMode, ".xml");

		// tilesets
		if (data.tilesets != null) for (tileset in data.tilesets) tilesets.push(Tileset.load(this, tileset));

		//Layer Templates
		for (layerData in data.layers)
		{
			var definitionId = layerData.definition;
			var definition = LayerDefinition.getDefinitionById(definitionId);
			var exportID:String = layerData.exportID;

			var template = definition.loadTemplate(exportID, layerData);
			template.projectWasLoaded(this);
			layers.push(template);
		}

		//Entity Templates
		if (data.entityTags != null) for (tag in data.entityTags) entities.tags.push(tag);
		
		for (entity in data.entities) entities.templates.push(EntityTemplate.load(entity));
		entities.refreshTagLists();

		initLastSavePath();
		return this;
	}

	public function save():ProjectSaveFile
	{
		var data:ProjectSaveFile = {
			name: name,
			levelPaths: levelPaths,
			backgroundColor: backgroundColor.toHexAlpha(),
			gridColor: gridColor.toHexAlpha(),
			anglesRadians: anglesRadians,
			levelDefaultSize: levelDefaultSize.save(),
			levelMinSize: levelMinSize.save(),
			levelMaxSize: levelMaxSize.save(),
			levelValues: ValueTemplate.saveList(this.levelValues),
			defaultExportMode: defaultExportMode,
			entityTags: entities.tags,
			layers: [for (layer in layers) layer.save()],
			entities: [for (entity in entities) entity.save()],
			tilesets: [for (tileset in tilesets) tileset.save()],
		};

		initLastSavePath();
		return data;
	}

	/*
			DEBUG
	*/

	public function logLayers()
	{
		for (layer in layers) trace(layer);
	}

	public static function createDebugProject():Project
	{
		return Import.project(Path.join('.', 'debugProject', 'debug.ogmo'));
	}
}

// TODO - I think some of these should be nullable -01010111
typedef ProjectSaveFile =
{
	name:String,
	levelPaths:Array<String>,
	backgroundColor:String,
	gridColor:String,
	anglesRadians:Bool,
	levelDefaultSize:{ x:Float, y:Float },
	levelMinSize:{ x:Float, y:Float },
	levelMaxSize:{ x:Float, y:Float },
	levelValues:Array<Dynamic>, // TODO: do we need more specific than this? -01010111
	defaultExportMode:String,
	entityTags:Array<String>,
	layers:Array<LayerTemplate>,
	entities:Array<EntityTemplate>,
	tilesets:Array<Tilesets>
}