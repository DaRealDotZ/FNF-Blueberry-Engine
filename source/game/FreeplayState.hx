package game;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton.FlxTypedButton;
import sys.io.File;
import haxe.Json;
import sys.FileSystem;
import engine.modding.Modding;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import game.menustuff.MenuItem;

using StringTools; // gonna be honest, 0 idea what this does.

class FreeplayState extends MusicBeatState
{  
    var menuItems:FlxTypedGroup<MenuItem> = new FlxTypedGroup();
    var playIcons:FlxGroup = new FlxGroup();

    var curSelected:Int = 0;

    override function create(){
        allowCamBeat = true;

        super.create();

        var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

        addMenuItem('playall', 'Play All');
        addMenuItem('shuffle', 'Shuffle and Play');

        loadMenu('week');

        for (mod in Modding.loadedMods){
            if (FileSystem.isDirectory('mods/$mod/weeks') == true){
                for (week in FileSystem.readDirectory('mods/$mod/weeks/')){
                    if (week != null && week.contains('.json')){
                        loadMenu('customWeek', mod, week);
                    }
                }
            }
        }

        add(menuItems);
        add(playIcons);
    }

    override function update(elapsed:Float){
        Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        if (Conductor.bpm != 102)
            Conductor.changeBPM(102);

        if (controls.DOWN_P){
            curSelected++;
        }
        else if (controls.UP_P){
            curSelected--;
        }

        if (curSelected < 0)
            curSelected = menuItems.members.length;
        else if (curSelected > menuItems.members.length){
            curSelected = 0;
        }

        for (item in menuItems.members){
            if (item.ID == curSelected){
                item.color = FlxColor.BLACK;
            }
            else if (item != null){
                item.color = FlxColor.WHITE;
            }

            if (item.ID == curSelected && (item.type.toLowerCase() == 'week' || item.type.toLowerCase() == 'customweek')){
                if (controls.ACCEPT){
                    var poop:String = Highscore.formatSong(item.weekData.songs[0].toLowerCase(), 1);

                    if (item.type.toLowerCase() != 'customweek'){
                        Modding.modLoaded = false;
                        Modding.curLoaded = "";

                        PlayState.SONG = Song.loadFromJson(poop, item.weekData.songs[0].toLowerCase());
                    }
                    else{
                        Modding.preloadData(item.modID);
                        Modding.modLoaded = true;
                        Modding.curLoaded = item.modID;

                        PlayState.SONG = Song.loadModChart(poop, item.weekData.songs[0].toLowerCase());
                    }

                    for (song in item.weekData.songs){
                        PlayState.songPlaylist.push({songName: song, modID: item.modID});
                    }

                    PlayState.isValidWeek = true;
					PlayState.gameDifficulty = 1;
		
					PlayState.storyWeek = item.weekData.week;
					trace('CUR WEEK' + PlayState.storyWeek);
		
					LoadingState.loadAndSwitchState(new PlayState());
                }
            }
        }
    }

    function loadMenu(menuType:String, ?menuID:String, ?menuName:String){
        var menu = menuType.toLowerCase();

        switch(menu){
            default:
                trace('uh... what the fuck do i go to, pal?');
            case 'customweek':
                var weekShit:WeekJson = Json.parse(File.getContent('mods/$menuID/weeks/$menuName'));

                for (week in weekShit.weeks){
                    addMenuItem('customweek', week.name, week.icon, week.iconIsJson, menuID, week);
                }
            case 'week':
                var weekShit:WeekJson = Json.parse(File.getContent(Paths.json('weeks', 'preload')));

                for (week in weekShit.weeks){
                    addMenuItem('week', week.name, week.icon, week.iconIsJson, null, week);
                }
        }
    }

    function addMenuItem(type:String, menuName:String, ?icon:String, ?isIconJson:Bool, ?theModID:String, ?weekData:WeekData){
        var menu = type.toLowerCase();
        var item:MenuItem;

        switch (menu){
            default:
                item = new MenuItem(32, (72 * menuItems.members.length) + 32, menuName, type);
            case 'week' | 'customweek':
                var amIMod:Bool = true;

                if (theModID == null && isIconJson == false) // untested
                    amIMod = false;

                item = new MenuItem(32, (72 * menuItems.members.length) + 32, menuName, type, weekData, theModID);
                var icon = new HealthIcon(icon, false, isIconJson, amIMod, -24);
                icon.setGraphicSize(Std.int(icon.width * 0.5));
                icon.sprTracker = item;

                playIcons.add(icon);
        }

        item.ID = menuItems.members.length + 1;

        menuItems.add(item);
    }
}

typedef WeekJson = {
	var weeks:Array<WeekData>;
}

typedef WeekData =
{
	var name:String;
	var songs:Array<String>;
	var week:Int;
	var icon:String;
    var iconIsJson:Bool;
	var ?isMod:Bool;
}