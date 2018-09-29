package com.monochrome.JDBC;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;

public class DBmetaData {

    public static void main() {
        try {
            Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost/tp1?useUnicode=true&useSSL=false&serverTimezone=UTC",
                    "javaDisciple",
                    "Turlututu!"
            );


            DatabaseMetaData dbmd = conn.getMetaData();
            String types[] = { "VIEW" };
            ResultSet res = dbmd.getTables(null, null, null, types);

            System.out.println("Views: ");
            while (res.next()) {
                System.out.println("    " + res.getString(3));
            }

            res =dbmd.getTables(null, null, null, new String[] {"TABLE"} );
            System.out.println("Tables: ");
            while ((res.next())) {
                System.out.println("    " + res.getString(3));
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

