package org.openmrs.module.mdrtbregistration.fragment.controller;

/**
 * Created by Dennis Henry on 12/20/2016.
 */
public class BirthDateModel {
    private String error, birthdate, age, ageInYear;
    boolean estimated;

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }


    public String getBirthdate() {
        return birthdate;
    }

    public void setBirthdate(String birthdate) {
        this.birthdate = birthdate;
    }

    public String getAge() {
        return age;
    }

    public void setAge(String age) {
        this.age = age;
    }

    public String getAgeInYear() {
        return ageInYear;
    }

    public void setAgeInYear(String ageInYear) {
        this.ageInYear = ageInYear;
    }

    public boolean isEstimated() {
        return estimated;
    }

    public void setEstimated(boolean estimated) {
        this.estimated = estimated;
    }
}
