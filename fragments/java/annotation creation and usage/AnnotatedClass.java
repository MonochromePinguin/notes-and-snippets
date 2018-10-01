package com.monochrome.annotations;

@TestInfos(
        priority = TestInfos.Priority.HIGH,
        createdBy = "Mitoo",
        tags = {"test", "experimental"},
        details = "bla, bla, blaaaaa ..."
)
public class AnnotatedClass {
    @TestRunnable
    void testAalwaysFail() {
        if (true) {
            System.out.println("testA() running ...");
            throw new RuntimeException("This test will always fail");
        }
    }

    @TestRunnable(active = false)
    void testBneverFail() {
        System.out.println("testB() running ...");
        if (false) {
            throw  new RuntimeException("This test will never fail");
        }
    }


    @TestRunnable(active = true)
    void testC() {
        System.out.println("testC() running ...");
        if (true) {
        }
    }

}
