package org.openmrs.module.mdrtbregistration.util;

import java.util.Calendar;
import java.util.Date;

/**
 * Created by Dennis Henry on 12/20/2016.
 */
public class PatientUtils {
    public static String estimateAge(Date date) {
        String age = "~";
        Calendar cal = Calendar.getInstance();
        Calendar cal2 = Calendar.getInstance();
        cal2.setTime(date);
        Date date2 = cal.getTime();
        int yearNew = cal.get(1);
        int yearOld = cal2.get(1);
        int monthNew = cal.get(2);
        int monthOld = cal2.get(2);
        int dayNew = cal.get(5);
        int dayOld = cal2.get(5);
        int maxDayInOldMonth = cal2.getActualMaximum(5);
        int yearDiff = yearNew - yearOld;
        int monthDiff = monthNew - monthOld;
        int dayDiff = dayNew - dayOld;
        int ageYear = yearDiff;
        int ageMonth = monthDiff;
        int ageDay = dayDiff;
        if(monthDiff < 0) {
            ageYear = yearDiff - 1;
            ageMonth = 12 - Math.abs(monthDiff);
        }

        if(dayDiff < 0) {
            --ageMonth;
            if(ageMonth < 0) {
                --ageYear;
                ageMonth = 12 - Math.abs(ageMonth);
            }

            ageDay = maxDayInOldMonth - dayOld + dayNew;
        }

        if(ageYear >= 1) {
            age = age + ageYear;
            if(ageMonth >= 6) {
                age = age + ".5";
            }

            if(ageYear == 1) {
                age = age + " year";
            } else {
                age = age + " years";
            }
        } else if(ageYear <= 0) {
            if(ageMonth >= 1) {
                if(ageMonth == 1) {
                    age = age + ageMonth + " month ";
                } else {
                    age = age + ageMonth + " months ";
                }
            }

            if(ageMonth <= 0) {
                if(ageDay != 1 && ageDay != 0) {
                    age = age + ageDay + " days ";
                } else {
                    age = age + ageDay + " day ";
                }
            }
        }

        return age;
    }

    public static String estimateAgeInYear(Date date) {
        Calendar cal = Calendar.getInstance();
        Calendar cal2 = Calendar.getInstance();
        cal2.setTime(date);
        int yearNew = cal.get(1);
        int yearOld = cal2.get(1);
        int yearDiff = yearNew - yearOld;
        String ageYear = String.valueOf(yearDiff);
        return ageYear;
    }
}
