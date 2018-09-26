package com.monochrome;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class Collection {

    private static final String[] listBuiling = {"ch1", "ch2", "ch3", "ch4"};

    public static void main() {
        ArrayList<String> tbl = new ArrayList<>();

        //ITERATOR ON A STRING[] :
        Iterator<String> iter = Arrays.stream(listBuilding).iterator();
        // OU BIEN
        // Iterator<String> iter = Arrays.asList(listBuilding).iterator();
        while (iter.hasNext()) {
            System.out.println(" -> " + iter.next());
        }

        for (String str : listBuiling) {
            tbl.add(str);
        }

        tbl.add("lastString");

        System.out.println( tbl.size() );

        //iterate through the list to print the content
        Iterator iter1 = tbl.iterator();
        while (iter1.hasNext()) {
            System.out.println(iter1.next());
        }

        //remove the entry at index 0
        tbl.remove(0);

        System.out.println(tbl);


        System.out.println("-------------------------------");


        Map hash1 = new HashMap<Integer, String>();
        hash1.put(33000, "v1");
        hash1.put(23000, "v2");
        hash1.put(13000, "v3");

        //print the whole hashMap
        System.out.println(hash1);


        // get the Map's Set equivalent (containing entry pairs of key-values) and iterate through it
        Iterator<Map.Entry> iter2 = hash1.entrySet().iterator();
        while (iter2.hasNext()) {
            Map.Entry pair = iter2.next();
            System.out.println(pair.getKey() + " =>; " + pair.getValue());
        }

        //delete an entry
        hash1.remove(13000);
        System.out.println(hash1);


        // iterate throught the same hashmap with a foreach and a lambda
        hash1.forEach( (key, value) -> {
                    System.out.println( key + " -> " + value);
                }
        );

        // a less performant way to iterate
        Iterator iter3 = hash1.values().iterator();
        while (iter3.hasNext()) {
            System.out.println( iter3.next() );
        }
        // idem
        Iterator<Integer> iter4 = hash1.keySet().iterator();
        while (iter4.hasNext()) {
            Integer i = iter4.next();
            System.out.println( i + " -> " + hash1.get(i) );
        }

    }
}
