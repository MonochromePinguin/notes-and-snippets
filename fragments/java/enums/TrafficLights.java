package com.monochrome.enums;

public class TrafficLights {

    private LightColors color;


    public TrafficLights(LightColors color) {
        this.color = color;
    }


    public LightColors getColor() {
        return color;
    }

    public void setColor(LightColors color) {
        this.color = color;
    }


    public void setColor(String color) throws IllegalArgumentException {
        switch (color.toLowerCase()) {
            case "red":
                this.color = LightColors.RED;
                break;
            case "orange":
                this.color = LightColors.ORANGE;
                break;
            case "green":
                this.color = LightColors.GREEN;
            default:
                throw new IllegalArgumentException();
        }
    }



    @Override
    public String toString() {
        return "Traffic light of ".concat( this.color.name()).concat(" color");
    }



    // MAIN //
    public static void main(String[] args) {
        TrafficLights fire1 = new TrafficLights(LightColors.getRandomOne());

        System.out.println(fire1);

        System.out.println(fire1.color.getMessage());
    }


}
