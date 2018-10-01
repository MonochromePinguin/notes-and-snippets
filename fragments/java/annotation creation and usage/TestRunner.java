package com.monochrome.annotations;

import java.lang.annotation.Annotation;
import java.lang.reflect.Method;

/***
 * use runtime reflexion to discover annotated classes.
 * for a faster but slighty more complex (compiler option, classpath and META-INF/services edition) way,
 *     read about  &laquo; Java Pluggable Annotation Processor &raquo;).
 *
 */
public class TestRunner { // throw IllegalArgumentException {

    public static void runTests(String className) {
        int passed = 0,
            failed = 0,
            totalNb = 0,
            ignored = 0;

        Class target;

        try {
            // get the class corresponding to that name...
            target = Class.forName(className);

        } catch (ClassNotFoundException e) {
            System.out.println("\n\nError: class « " + className + " » not found.");
            return;
        }

        System.out.println("\n\n--------------------------");
        System.out.println("Testing in flight for the class « " + target.getName() + " » ...");


        //print all present data from annotation « testInfo »
        //

        if (target.isAnnotationPresent(TestInfos.class)) {
            Annotation annotation = target.getAnnotation(TestInfos.class);
            TestInfos testInfo = (TestInfos) annotation;

            System.out.printf("Priority:%s%n", testInfo.priority());
            System.out.printf("Created by:%s%n", testInfo.createdBy());
            System.out.printf("Last modified:%s%n", testInfo.lastModification());
            System.out.printf("Details:%n    %s%n", testInfo.details());

            System.out.printf("Tags:%n    ");
            int nbTags = testInfo.tags().length;
            for (String tag : testInfo.tags()) {
                if (nbTags-- > 1) {
                    System.out.print(tag.concat(", "));
                } else {
                    System.out.print(tag.concat("\n\n"));
                }
            }

        }


        //Run tests
        //
        for (Method method : target.getDeclaredMethods()) {
            if (method.isAnnotationPresent(TestRunnable.class)) {

                TestRunnable runAnnotation = (TestRunnable) method.getAnnotation(TestRunnable.class);
                if (runAnnotation.active()) {

                    try {
                        method.invoke(target.newInstance());

                        System.out.println("Testing of « ".concat(method.getName()).concat(" » : OK"));
                        ++passed;

                    } catch (Exception e) {
                        System.out.println("Testing of « ".concat(method.getName()).concat(" » : FAILED"));
                        ++failed;
                    }

                } else {
                    System.out.println("untested: ".concat(method.getName()));
                    ++ignored;
                }

                ++totalNb;
            }
            System.out.println();
        }

        System.out.printf("%n%nFinally: %d tests counted, %d not run, %d successes, %d fails%n", totalNb, ignored, passed, failed);
    }


    public static void main(String[] args) {
        runTests("com.monochrome.annotations.AnnotatedClass");
    }

}
