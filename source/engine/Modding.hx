package engine;

import openfl.utils.AssetCache;
import sys.io.File;
import sys.FileSystem;

class Modding {
    public var isInit:Bool = false;

    public static var loadedMods:Array<String> = [];
    public static var curLoaded:String;

    //public static var moddedAssets:AssetCache = new AssetCache();

    public static function init(){
        trace('Initializing');
    }
}