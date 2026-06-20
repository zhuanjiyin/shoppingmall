package util;

import java.util.Random;

public class IdUtils {
    public static String genId() {
        long millis = System.currentTimeMillis();
        Random random = new Random();
        int end2 = random.nextInt(99);
        return millis + String.format("%02d", end2);
    }
}