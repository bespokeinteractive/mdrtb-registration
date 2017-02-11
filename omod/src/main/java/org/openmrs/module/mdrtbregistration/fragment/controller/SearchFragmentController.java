package org.openmrs.module.mdrtbregistration.fragment.controller;

import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mdrtb.program.MdrtbPatientProgram;
import org.openmrs.module.mdrtbdashboard.MdrtbPatientWrapper;
import org.openmrs.module.mdrtbdashboard.api.MdrtbDashboardService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Dennis Henry on 2/2/2017.
 */

public class SearchFragmentController {
    public List<SimpleObject> searchPatient(
            @RequestParam(value = "phrase", required = false) String phrase,
            UiUtils ui,
            HttpServletRequest request) {
        String gender = request.getParameter("gender");
        String lastDayOfVisit = request.getParameter("lastDayOfVisit");
        if (gender.equalsIgnoreCase("any")) {
            gender = null;
        }
        if (lastDayOfVisit.equalsIgnoreCase("")) {
            lastDayOfVisit = null;
        }

        Integer age = getInt(request.getParameter("age"));
        Integer ageRange = getInt(request.getParameter("ageRange"));
        Integer lastVisitRange = getInt(request.getParameter("lastVisit"));
        Integer programId = getInt(request.getParameter("programId"));

        List<MdrtbPatientProgram> mdrtbPatients = Context.getService(MdrtbDashboardService.class).getMdrtbPatients(phrase, gender, age, ageRange, lastDayOfVisit, lastVisitRange, programId);
        List<MdrtbPatientWrapper> wrapperList = mdrtbPatientsWithDetails(mdrtbPatients);

        return SimpleObject.fromCollection(wrapperList, ui, "patientProgram", "wrapperIdentifier", "wrapperNames", "wrapperStatus", "formartedVisitDate", "patientProgram.patient.patientId", "patientProgram.patient.age", "patientProgram.patient.gender");
    }

    private Integer getInt(String value) {
        try {
            Integer number = Integer.parseInt(value);
            return number;
        } catch (Exception e) {
            return 0;
        }
    }

    private List<MdrtbPatientWrapper> mdrtbPatientsWithDetails(List<MdrtbPatientProgram> mdrtbPatients) {
        List<MdrtbPatientWrapper> wrappers = new ArrayList<MdrtbPatientWrapper>();
        for (MdrtbPatientProgram patientProgram : mdrtbPatients) {
            MdrtbPatientWrapper pw = new MdrtbPatientWrapper(patientProgram);
            wrappers.add(pw);
        }
        return wrappers;
    }
}
