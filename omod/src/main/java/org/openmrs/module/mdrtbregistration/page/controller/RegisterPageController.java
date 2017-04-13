package org.openmrs.module.mdrtbregistration.page.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.mdrtb.model.PersonLocation;
import org.openmrs.module.mdrtb.service.MdrtbService;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.text.DateFormat;
import java.text.ParsePosition;
import java.util.*;

import java.text.SimpleDateFormat;

/**
 * Created by Dennis Henry on 12/15/2016.
 */

public class RegisterPageController {
    private static Log logger = LogFactory.getLog(RegisterPageController.class);

    public String get(
            @RequestParam(value = "names", required=false) String names,
            @RequestParam(value = "gender", required=false) String gender,
            @RequestParam(value = "birthdate", required=false) String birthdate,
            @RequestParam(value = "estimate", required=false) String estimate,
            PageModel model,
            UiUtils ui) {

        if (gender.equals("undefined")){
            gender="";
        }

        model.addAttribute("birthdate", birthdate);
        model.addAttribute("names", names);
        model.addAttribute("gender", gender);
        model.addAttribute("estimate", estimate);

        return null;
    }

    public String post(HttpServletRequest request,
                       PageModel model,
                       UiUtils ui,
                       UiSessionContext session) throws IOException {
        // list all parameter submitted
        Map<String, Object> params=new HashMap<String, Object>();

        DateFormat df = new SimpleDateFormat("dd/MM/yyyy");
        Date birthDate = df.parse(request.getParameter("patient.birthdate"), new ParsePosition(0));
        Boolean estimated = Boolean.parseBoolean(request.getParameter("patient.birthdateEstimated"));

        SimpleDateFormat sdf = new SimpleDateFormat("yyMMddHHmmssS");
        Calendar calendar = Calendar.getInstance();
        Random random = new Random();

        String identifier =  sdf.format(calendar.getInstance().getTime()) + random.nextInt(9999);
        String givenName = "";
        String familyName = "";
        String otherNames = "";

        String[] nameList = request.getParameter("patient.name").split("\\s+");

        for (int i=0; i<nameList.length; i++){
            if (i ==0){
                givenName = nameList[i];
            }
            else if (i==1){
                familyName = nameList[i];
            }
            else{
                otherNames += nameList[i] + " ";
            }
        }

        PersonName pn = new PersonName();
        pn.setGivenName(givenName);
        pn.setFamilyName(familyName);
        pn.setMiddleName(otherNames);

        PatientIdentifier pi = new PatientIdentifier();
        pi.setIdentifier(identifier);
        pi.setIdentifierType(new PatientIdentifierType(2));
        pi.setLocation(new Location(2));
        pi.setDateCreated(new Date());

        PersonAddress pa = new PersonAddress();
        pa.setAddress1(request.getParameter("address.address1"));
        pa.setAddress2(request.getParameter("address.address2"));
        pa.setCountry(request.getParameter("address.country"));
        pa.setCityVillage(request.getParameter("address.cityVillage"));
        pa.setStateProvince(request.getParameter("address.stateProvince"));
        pa.setPreferred(true);

        Patient patient = new Patient();
        patient.addName(pn);
        patient.addAddress(pa);
        patient.addIdentifier(pi);
        patient.setGender(request.getParameter("patient.gender"));
        patient.setBirthdate(birthDate);
        patient.setBirthdateEstimated(estimated);

        patient = Context.getPatientService().savePatient(patient);

        PersonLocation pl = new PersonLocation();
        pl.setPerson(patient);
        pl.setLocation(session.getSessionLocation());
        pl.setDescription("Registration");
        Context.getService(MdrtbService.class).savePersonLocation(pl);

        params.put("patient", patient);

        return "redirect:" + ui.pageLink("mdrtbdashboard", "enroll", params);
    }
}
