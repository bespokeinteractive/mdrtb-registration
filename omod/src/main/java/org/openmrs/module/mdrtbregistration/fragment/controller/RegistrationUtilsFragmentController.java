package org.openmrs.module.mdrtbregistration.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.module.mdrtbregistration.util.RegistrationUtils;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.ParseException;
import java.util.Calendar;
import java.util.Date;

/**
 * Created by Dennis Henry on 12/20/2016.
 */
public class RegistrationUtilsFragmentController {
    private static Log logger = LogFactory.getLog(RegistrationUtilsFragmentController.class);

    public SimpleObject processPatientBirthDate(
            @RequestParam("birthdate") String birthdate,
            FragmentModel model, UiUtils utils) throws ParseException {
        BirthDateModel dateModel=new BirthDateModel();
        // try to parse date
        // if success -> it's a birthdate
        // otherwise -> it's an age
        Date date = null;
        try {
            date = RegistrationUtils.parseDate(birthdate);
        } catch (ParseException e) {

        }
        if (date != null) {

            if (isLaterToday(date)) {
                dateModel.setError("Birthdate must be before the current date.");
            } else {
                // the user entered the correct birthdate
                dateModel.setEstimated(false);
                dateModel.setBirthdate(birthdate);
                dateModel.setAge( RegistrationUtils.estimateAge(birthdate).replace("~", ""));
                dateModel.setAgeInYear(RegistrationUtils.estimateAgeInYear(birthdate));
                logger.info("User entered the correct birthdate.");
            }

        } else {

            String lastLetter = birthdate.substring(birthdate.length() - 1).toLowerCase();
            if ("ymwd".indexOf(lastLetter) < 0) {
                dateModel.setError("Age in wrong format");
            } else {
                try {
                    dateModel.setEstimated(true);
                    String estimatedBirthdate = getEstimatedBirthdate(birthdate);
                    dateModel.setBirthdate(estimatedBirthdate);
                    dateModel.setAge(RegistrationUtils.estimateAge(estimatedBirthdate));
                    dateModel.setAgeInYear(RegistrationUtils.estimateAgeInYear(estimatedBirthdate));
                } catch (Exception e) {
                    dateModel.setError("Error Processing Date"+e.getMessage());
                }
            }
        }
        //model.addAttribute("json", json);
        return SimpleObject.create("datemodel",dateModel);
    }

    private boolean isLaterToday(Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(new Date());
        c.set(Calendar.HOUR, 0);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        return date.after(c.getTime());
    }

    private String getEstimatedBirthdate(String text) throws Exception {
        text = text.toLowerCase();
        String ageStr = text.substring(0, text.length() - 1);
        String type = text.substring(text.length() - 1);
        int age = Integer.parseInt(ageStr);
        if (age < 0) {
            throw new Exception("Age must not be negative number!");
        }
        Calendar date = Calendar.getInstance();
        if (type.equalsIgnoreCase("y")) {
            date.add(Calendar.YEAR, -age);
        } else if (type.equalsIgnoreCase("m")) {
            date.add(Calendar.MONTH, -age);
        } else if (type.equalsIgnoreCase("w")) {
            date.add(Calendar.WEEK_OF_YEAR, -age);
        } else if (type.equalsIgnoreCase("d")) {
            date.add(Calendar.DATE, -age);
        }
        return RegistrationUtils.formatDate(date.getTime());
    }
}
