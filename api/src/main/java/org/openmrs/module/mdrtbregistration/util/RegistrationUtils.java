package org.openmrs.module.mdrtbregistration.util;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by Dennis Henry on 12/20/2016.
 */
public class RegistrationUtils {
    private static Log logger = LogFactory.getLog(RegistrationUtils.class);

    /**
     * Parse Date
     *
     * @param date
     * @return
     * @throws ParseException
     */
    public static Date parseDate(String date) throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.parse(date);
    }

    public static String estimateAge(String birthdate) throws ParseException {
        Date date = RegistrationUtils.parseDate(birthdate);
        return PatientUtils.estimateAge(date);
    }

    public static String estimateAgeInYear(String birthdate) throws ParseException {
        Date date = RegistrationUtils.parseDate(birthdate);
        return PatientUtils.estimateAgeInYear(date);
    }

    public static String formatDate(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.format(date);
    }
}
