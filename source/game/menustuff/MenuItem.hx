package game.menustuff;

import game.FreeplayState.WeekData;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class MenuItem extends FlxText{
    public var weekData:WeekData;
    public var type:String;
    public var modID:String;


    public function new(x:Float, y:Float, text:String, type:String, ?weekData:WeekData, ?modID:String, size:Int = 64, facing:FlxTextAlign = LEFT){
        super(x, y);
        this.text = text;
        this.type = type;
        this.setFormat(Paths.font("PhantomMuff.ttf"), size, FlxColor.WHITE, facing);
        setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 2);

        if (type.toLowerCase() == 'week' || type.toLowerCase() == 'customweek'){
            this.weekData = weekData;
            this.modID = modID;
        }
    }
}