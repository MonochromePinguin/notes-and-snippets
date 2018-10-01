package com.monochrome.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)           // → signifie « CLASS »
public @interface TestInfos {        // → « @ANNOTATION » en fait ...

    public enum Priority { LOW, MEDIUM, HIGH };

    Priority priority() default Priority.MEDIUM;
    String[] tags() default "";
    String createdBy() default "MouDuChou";
    String lastModification() default "28/09/2018";
    public String details();
}
