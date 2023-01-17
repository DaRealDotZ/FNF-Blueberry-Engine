package engine.optionsMenu;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;

class TextOption extends FlxText
{
    public var funnyOptionType:Int = 0; // 0 - on/off | 1 - New Menu | 2 - Switch State

    public function new(x:Float, y:Float, text:String, optionType:Int){
        super(x, y, FlxG.width, text, 72);

        setFormat("PhantomMuff 1.5", 72, FlxColor.WHITE, "center");
        setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 5, 1);
        setSize(width, height * 1.25);
        antialiasing = true;

        funnyOptionType = optionType;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}