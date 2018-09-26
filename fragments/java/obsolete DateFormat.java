// OBSOLETE DateFormat, Locale.setDefault()

package com.monochrome.datesFunctions;

import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

public class dateFunctions {

    public static void main(String[] args) {

        //localize the date output
        Locale.setDefault(Locale.FRENCH);

        Date today = new Date(); // NOW
        Date yesterday = new Date(84, 11, 21); //ATTENTION : Δ since 1900 !

        DateFormat shortDateFormat = DateFormat.getDateTimeInstance(DateFormat.SHORT, DateFormat.SHORT);
        DateFormat longDateFormat = DateFormat.getDateTimeInstance(DateFormat.LONG, DateFormat.LONG);


        System.out.println( "today, short format: " + shortDateFormat.format(today));
        System.out.println("today, long format: " + longDateFormat.format(today));


        String cmp;
        switch (today.compareTo(yesterday)) {
            case -1:
                cmp = "before ";
                break;
            case 0:
                cmp = "equal to ";
                break;
            default:
                cmp = "after ";
        }
        System.out.println( longDateFormat.format(today) + " is " + cmp + longDateFormat.format(yesterday) );
    }
}

