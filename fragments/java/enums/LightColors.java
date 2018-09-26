package com.monochrome.enums;

import java.util.Random;

public enum LightColors {
    //enum values can have (retrievable) properties
    GREEN("orange", true),
    ORANGE("orange", true, "Beware"),
    RED("red", false, "Thou Should not pass!"),
    BLINKING_PINK("a bizarre shade-varying pink", false, "It's really WEIRD!");

    private final boolean canPass;
    private final String name;
    private final String message;


    //the 2-parameters constructor call the 3-parameters constructor by using this(...)
    LightColors(String name, boolean canPass) {
        this(name, canPass, "Go quietly ...");
    }

    LightColors(String elegantName, boolean canPass, String message) {
        this.name = elegantName;
        this.canPass = canPass;
        this.message = message;
    }


    public boolean canPass() {
        return this.canPass;
    }

    public String getName() {
        return this.name;
    }

    public String getMessage() {
        return this.message;
    }

    //GET A RANDOM VALUE
    public static LightColors getRandomOne() {
        LightColors[] colors = LightColors.values();
        return colors[ new Random().nextInt(colors.length) ];
    }

}
