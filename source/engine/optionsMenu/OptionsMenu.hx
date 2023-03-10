package engine.optionsMenu;

import engine.optionsMenu.keybinds.KeybindsState;
import game.MainMenuState;
import Controls.Action;
import cpp.abi.Abi;
import haxe.ds.Option;
import openfl.system.System;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSubState;
import engine.optionsMenu.TextOption;

using StringTools;

class OptionsMenu extends MusicBeatState {
	var funnyOption:TextOption;
	var background:FlxSprite;
	var camFollow:FlxSprite;

	var curSelected:Int = 0;
	var curMenu:String = '';
	var curOptions:Array<Dynamic> = [];
	
	var optionsGroup:FlxTypedGroup<TextOption>;

	var gameplayOptions:Array<Dynamic> = [ //display name, description, save variable name
	    ['Ghost Tapping',"Disables missing once you press a key when a note is not there",'disableGhostTap'],
	    ['Downscroll',"Sets the Notes position to the bottom",'downScroll'],
	    ['Middlescroll',"Sets the Notes position to the middle",'middleScroll'],
	    ['Botplay',"Allows a bot to play the game for you",'botplay'],
    ];
    var graphicsOptions:Array<Dynamic> = [ //display name, description, save variable name
	    ['Distractions',"Toggle Distractions",'noDistractions'],
	    ['Epilepsy',"Disables most flashing lights",'epilepsyMode'],
	    ['Show Outdated Screen',"Toggle Outdated Screen",'disableOutdatedScreen']
    ];
    var sections:Array<Dynamic> = [];

	var optionDetails:FlxText;

	override function create() {
		sections.push(['Keybinds','default']);
		sections.push(['Gameplay','default']);
		sections.push(['Graphics','default']);
		sections.push(['Modding','default']);

		background = new FlxSprite(0, 0, Paths.image('menuBGBlue'));
		background.scrollFactor.x = 0;
		background.scrollFactor.y = 0;
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = true;
		add(background);

		optionsGroup = new FlxTypedGroup<TextOption>();

		generateOptions(true);

		add(optionsGroup);

		optionDetails = new FlxText(0, 0, FlxG.width, "");
		optionDetails.setFormat("PhantomMuff 1.5", 32, 0xFF000000, "center");
		optionDetails.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF, 2, 1);
		optionDetails.scrollFactor.set();
		optionDetails.antialiasing = true;
		add(optionDetails);

		camFollow = new FlxSprite(0, 0).makeGraphic(Std.int(optionsGroup.members[0].width), Std.int(optionsGroup.members[0].height), 0xAAFF0000);
		camFollow.y = optionsGroup.members[0].y;
		FlxG.camera.follow(camFollow, null, 0.06);

		super.create();
	}

	override function update(elapsed:Float) {
		if (optionsGroup.members[curSelected] != null){
			camFollow.y = optionsGroup.members[curSelected].y;
		}

		for (option in optionsGroup){
			if (option != null){
				if (optionsGroup.members[curSelected] != option)
					option.alpha = 0.6;
				else
					option.alpha = 1;
			}
		}

		if (controls.DOWN_P && curSelected < optionsGroup.members.length - 1 || controls.UP_P && curSelected > 0)
			FlxG.sound.play(Paths.sound('scrollMenu', 'preload'));

		if (controls.DOWN_P && curSelected < optionsGroup.members.length - 1)
			curSelected++;
		if (controls.UP_P && curSelected > 0)
			curSelected--;
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('scrollMenu', 'preload'));
			optionSelected();
		}
		if (controls.BACK){
			curSelected = 0;

			if (curMenu != 'default')
				generateOptions(true);
			else
				FlxG.switchState(new MainMenuState());

			FlxG.sound.play(Paths.sound('cancelMenu', 'preload'));
		}

		#if desktop
		if (FlxG.save.data.allowMods == null)
			FlxG.save.data.allowMods = true;
		#end

		switch(curMenu)
		{
			case 'gameplay':
				optionDetails.text = gameplayOptions[curSelected][1];
			case 'graphics':
				optionDetails.text = graphicsOptions[curSelected][1];
			default:
				optionDetails.text = "";
				optionDetails.text = '';
		}
		//optionDetails.text = curOptions[curSelected][1];
	}

	function generateOptions(?theOptionGroup:String = null,?sectionGeneration:Bool = false){
		var optionArray:Array<String> = [];
		var optionSelectionProperties:Array<Int> = []; // 0 - on/off | 1 - New Menu | 2 - Switch State

		for (option in optionsGroup){
			if (option != null){
				option.destroy();
			}
		}

		optionsGroup.clear();

		switch (theOptionGroup.toLowerCase())
		{
			default:
				optionSelectionProperties = [2, 1, 1, 2];
				curMenu = 'default';
			case 'gameplay':
				optionSelectionProperties = [0, 0, 0, 0, 0, 0, 0];
			case 'graphics':
				optionSelectionProperties = [0, 0, 0, 0, 0];
		}

		if (sectionGeneration)
		{
			for (num in 0...sections.length) 
			{
				if (curMenu == 'default')
				{
					funnyOption = new TextOption(0, 0, sections[num][0], optionSelectionProperties[num]);
					funnyOption.screenCenter(Y);
					funnyOption.y = 78 * num;
					optionsGroup.add(funnyOption);
				}
			}
		}
		else
		{
			for (num in 0...curOptions.length) 
			{
				funnyOption = new TextOption(0, 0, curOptions[num][0], optionSelectionProperties[num], Reflect.getProperty(engine.OptionsData,curOptions[num][2]));
				funnyOption.screenCenter(Y);
				funnyOption.y = 78 * num;
				optionsGroup.add(funnyOption);
			}
		}
	}

	function optionSelected(){
		trace('option type: ' + optionsGroup.members[curSelected].funnyOptionType + ' option text: '+ optionsGroup.members[curSelected].text);

		switch (optionsGroup.members[curSelected].funnyOptionType){ // messy but in my opinion it works better than the old system
			case 0:
				Reflect.setProperty(engine.OptionsData, curOptions[curSelected][2], !Reflect.getProperty(engine.OptionsData,curOptions[curSelected][2]));

				engine.OptionsData.dumpData();
				engine.OptionsData.loadData();

				optionsGroup.members[curSelected].refreshText(Reflect.getProperty(engine.OptionsData,curOptions[curSelected][0]),Reflect.getProperty(engine.OptionsData,curOptions[curSelected][2]));

				trace('Option State: ${Reflect.getProperty(engine.OptionsData,curOptions[curSelected][2])}'); 

				generateOptions(curMenu,false); //reload the current menu
			case 1:
				switch (optionsGroup.members[curSelected].text.toLowerCase())
				{
					case 'gameplay':
						curMenu = 'gameplay';
						curOptions = gameplayOptions;
					case 'graphics':
						curMenu = 'graphics';
						curOptions = graphicsOptions;
				}
				generateOptions(curMenu,false);
				curSelected = 0;
			case 2:
				switch(optionsGroup.members[curSelected].text.toLowerCase()){
					case 'keybinds':
						FlxG.switchState(new KeybindsState());
					case 'modding':
						FlxG.sound.play(Paths.sound('badnoise3', 'shared'));
				}
			default:
				trace('error lmao');
		}
	}
}
