package project.editor;

import js.jquery.JQuery;
import util.Vector;
import util.Color;
import util.Fields;

class ProjectGeneralPanel extends ProjectEditorPanel
{

  public var projectName:JQuery;
  public var backgroundColor:JQuery;
  public var gridColor:JQuery;
  public var angleExport:JQuery;
  public var levelMinSize:JQuery;
  public var levelMaxSize:JQuery;
	public var levelValueManager:ValueTemplateManager;

  public function new()
  {
    super(0, "general", "General", "sliders");
    // general settings

    projectName = Fields.createField("Project Name");
    Fields.createSettingsBlock(root, projectName, SettingsBlock.Full, "Name", SettingsBlock.InlineTitle);

    backgroundColor = Fields.createColor("Background Color", Color.white, root);
    Fields.createSettingsBlock(root, backgroundColor, SettingsBlock.Third, "Bg Color", SettingsBlock.InlineTitle);

    gridColor = Fields.createColor("Grid Color", Color.white);
    Fields.createSettingsBlock(root, gridColor, SettingsBlock.Third, "Grid Color", SettingsBlock.InlineTitle);

    angleExport = Fields.createOptions({ "0": "Radians", "1": "Degrees" });
    Fields.createSettingsBlock(root, angleExport, SettingsBlock.Third, "Angle Export Mode", SettingsBlock.InlineTitle);

    // level size
    levelMinSize = Fields.createVector(new Vector(0, 0));
    Fields.createSettingsBlock(root, levelMinSize, SettingsBlock.Half, "Min. Level Size", SettingsBlock.InlineTitle);
    levelMaxSize = Fields.createVector(new Vector(0, 0));
    Fields.createSettingsBlock(root, levelMaxSize, SettingsBlock.Half, "Max. Level Size", SettingsBlock.InlineTitle);

    // level custom fields
    levelValueManager = new ValueTemplateManager(root, []);
  }

  override function begin():Void
  {
    Fields.setField(projectName, Ogmo.ogmo.project.name);
    Fields.setColor(backgroundColor, Ogmo.ogmo.project.backgroundColor);
    Fields.setColor(gridColor, Ogmo.ogmo.project.gridColor);
    angleExport.val(Ogmo.ogmo.project.anglesRadians ? "0" : "1");
    Fields.setVector(levelMinSize, Ogmo.ogmo.project.levelMinSize);
    Fields.setVector(levelMaxSize, Ogmo.ogmo.project.levelMaxSize);
    levelValueManager.inspect(null, false);
    levelValueManager.values = Ogmo.ogmo.project.levelValues;
    levelValueManager.refreshList();
  }

  override function end():Void
  {
    Ogmo.ogmo.project.name = projectName.val();
    Ogmo.ogmo.project.backgroundColor = Fields.getColor(backgroundColor);
    Ogmo.ogmo.project.gridColor = Fields.getColor(gridColor);
    Ogmo.ogmo.project.anglesRadians = angleExport.val() == "0";
    Ogmo.ogmo.project.levelMinSize = Fields.getVector(levelMinSize);
    Ogmo.ogmo.project.levelMaxSize = Fields.getVector(levelMaxSize);
    Ogmo.ogmo.project.levelValues = levelValueManager.values;
  }
}

// TODO
// (<any>window).startup.push(function()
// {
//     projectEditor.addPanel(new ProjectGeneralPanel());
// });