// DateTimeFormatter.ofPattern(), DateFormatSymbols, LocalDate.plus/minus//Days/Weeks/Years, formatter.format
package com.monochrome.datesFunctions;

import java.text.DateFormatSymbols;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class JoursFr {
    public static void main(String[] args) {

        final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");

        //GET A LOCALIZED LIST OF DAYS
        for(String str : new DateFormatSymbols(Locale.FRENCH).getWeekdays() ) {
            System.out.println(str);
        }

        System.out.println();

        System.out.println( "Today's date: " + formatter.format(LocalDate.now()));
        System.out.println( "Tomorrow's: " + formatter.format( LocalDate.now().plusDays(1) ) );
        System.out.println("Ten days ago: " + formatter.format( LocalDate.now().minusDays(10)));

    }
}
