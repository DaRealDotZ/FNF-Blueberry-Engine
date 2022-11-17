package engine;

import openfl.media.Sound;
import lime.utils.AssetCache;
import lime.graphics.Image;
import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;

class Modding {
    public var isInit:Bool = false;

    public static var loadedMods:Array<String> = [];
    public static var curLoaded:String;
    
    public static var modLoaded:Bool = false;

    public static function init(){
        trace('Initializing');

        if (FileSystem.readDirectory('mods/') != null){
            var modFolders:Array<String> = FileSystem.readDirectory('mods/');

            for (i in 0...modFolders.length){
                if (FileSystem.exists('mods/' + modFolders[i] + '/mod.json')){
                    loadedMods.push(modFolders[i]);

                    if (File.getContent('mods/'+ modFolders[i] +'/mod.json') == ''){
                        File.saveContent('mods/'+ modFolders[i] +'/mod.json', Json.stringify({
                            "name": modFolders[i],
                            "description": "",
                            "author": "",
                            "version": "1.0"
                        }));
                    }

                    trace('Succesfully imported mod: ' + modFolders[i]);
                }
            }
        }
        else{
            return;
        }
    }

    public static function retrieveImage(asset:String, library:String = 'images'){
        return BitmapData.fromFile('mods/$curLoaded/$library/$asset.png');
    }
    
    public static function retrieveAudio(asset:String, library:String = 'songs'){
        return Sound.fromFile('mods/$curLoaded/$library/$asset.ogg');
    }

    public static function retrieveTextArray(asset:String, library:String):Array<String>
    {
        var daList:Array<String> = File.getContent('mods/$curLoaded/$library/$asset').split('\n');
    
        return daList;
    }

    public static function retrieveContent(asset:String, library:String):String{
        return File.getContent('mods/$curLoaded/$library/$asset');
    }

    public static function getFilePath(asset:String, library:String){
        return 'mods/$curLoaded/$library/$asset';
    }

    public static function modCharacterArray():Array<Dynamic>{ // not tested
        var charList:Array<String> = [];

        if (FileSystem.exists('mods/$curLoaded/data/characters/') && FileSystem.readDirectory('mods/$curLoaded/data/characters/') != null){
            for (char in FileSystem.readDirectory('mods/$curLoaded/data/characters/')){
                var temp:Array<String> = [];

                temp = char.split('.json');
                temp.remove('.json');

                charList.push(temp.toString());
            }

            return charList;
        }
        else
            return [];
    }
}