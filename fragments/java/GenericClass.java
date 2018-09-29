package com.monochrome.genericity;

// a generic class
public class Generic<T, T2, blog> {
    // the types given in square bracket are reusable
    private T attributeOne;
    private T2 attr2;
    private blog attr3;


    public Generic() {
        this.attributeOne = null;
        this.attr2 = null;
        this.attr3 = null;
    }


    public Generic(T attribute) {
        this.attributeOne = attribute;
    }

    public Generic(T attributeOne, T2 attr2, blog attr3) {
        this.attributeOne = attributeOne;
        this.attr2 = attr2;
        this.attr3 = attr3;
    }

    public T getAttributeOne() {
        return attributeOne;
    }
    public void setAttributeOne(T attributeOne) {
        this.attributeOne = attributeOne;
    }

    public T2 getAttr2() { return attr2; }
    public void setAttr2(T2 attr2) { this.attr2 = attr2; }

    public blog getAttr3() { return attr3; }
    public void setAttr3(blog attr3) { this.attr3 = attr3; }
}
