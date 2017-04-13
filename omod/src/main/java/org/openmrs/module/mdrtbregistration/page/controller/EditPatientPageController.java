package org.openmrs.module.mdrtbregistration.page.controller;

import org.openmrs.Patient;
import org.openmrs.PersonAddress;
import org.openmrs.PersonName;
import org.openmrs.api.context.Context;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.text.DateFormat;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Dennis Henry
 * Created on 2/7/2017.
 */
public class EditPatientPageController {
    public void get(
            @RequestParam(value = "patient")Patient patient,
            PageModel model,
            UiUtils ui) {
        DateFormat df = new SimpleDateFormat("dd/MM/yyyy");
        model.addAttribute("patient", patient);
        model.addAttribute("birthdate", df.format(patient.getBirthdate()));
    }

    public String post(HttpServletRequest request,
                       PageModel model,
                       UiUtils ui) throws IOException {
        Map<String, Object> params=new HashMap<String, Object>();
        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(request.getParameter("patient.id")));
        DateFormat df = new SimpleDateFormat("dd/MM/yyyy");
        Date birthDate = df.parse(request.getParameter("patient.birthdate"), new ParsePosition(0));
        Boolean estimated = Boolean.parseBoolean(request.getParameter("patient.birthdateEstimated"));

        String fullNames = request.getParameter("patient.name").trim();
        String givenName = "";
        String familyName = "";
        String otherNames = "";

        String[] nameList = fullNames.split("\\s+");
        for (int i=0; i<nameList.length; i++){
            if (i ==0)
                givenName = nameList[i];
            else if (i==1)
                familyName = nameList[i];
            else{
                otherNames += nameList[i] + " ";
            }
        }

        PersonName pn = patient.getPersonName();
        pn.setGivenName(givenName);
        pn.setFamilyName(familyName);
        pn.setMiddleName(otherNames);

        PersonAddress pa = patient.getPersonAddress();
        if (pa == null){
            pa = new PersonAddress();
        }

        pa.setAddress1(request.getParameter("address.address1"));
        pa.setAddress2(request.getParameter("address.address2"));
        pa.setCountry(request.getParameter("address.country"));
        pa.setCityVillage(request.getParameter("address.cityVillage"));
        pa.setStateProvince(request.getParameter("address.stateProvince"));
        pa.setPreferred(true);

        patient.addName(pn);
        patient.addAddress(pa);
        patient.setBirthdate(birthDate);
        patient.setBirthdateEstimated(estimated);

        //Save Patient Details
        Context.getPatientService().savePatient(patient);

        params.put("phrase", fullNames);
        return "redirect:" + ui.pageLink("mdrtbregistration", "search", params);
    }
}
