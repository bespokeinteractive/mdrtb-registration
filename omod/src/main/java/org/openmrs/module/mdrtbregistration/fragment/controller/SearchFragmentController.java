package org.openmrs.module.mdrtbregistration.fragment.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Concept;
import org.openmrs.Location;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mdrtb.program.MdrtbPatientProgram;
import org.openmrs.module.mdrtb.service.MdrtbService;
import org.openmrs.module.mdrtbdashboard.MdrtbPatientWrapper;
import org.openmrs.module.mdrtbdashboard.api.MdrtbDashboardService;
import org.openmrs.module.mdrtbdashboard.model.PatientProgramDetails;
import org.openmrs.module.mdrtbdashboard.util.DateRangeModel;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Dennis Henry
 * Created on 2/2/2017.
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
        Integer locationId = getInt(request.getParameter("locations"));
        Integer activeOnly = getInt(request.getParameter("active"));

        String daamin = request.getParameter("daamin");
        String enrolled = request.getParameter("enrolled");
        String finished = request.getParameter("finished");

        Integer status = getInt(request.getParameter("status"));
        Integer site = getInt(request.getParameter("site"));
        Integer outcome = getInt(request.getParameter("outcome"));
        Integer diagnosis = getInt(request.getParameter("diagnosis"));
        Integer artstatus = getInt(request.getParameter("artstatus"));
        Integer cptstatus = getInt(request.getParameter("cptstatus"));

        if (activeOnly == 1){
            programId = -1;
        }

        List<Location> locations = getLocations(locationId);

        List<MdrtbPatientProgram> mdrtbPatients = Context.getService(MdrtbDashboardService.class).getMdrtbPatients(phrase, gender, age, ageRange, lastDayOfVisit, lastVisitRange, programId, locations);
        List<MdrtbPatientWrapper> wrapperList = mdrtbPatientsWithDetails(mdrtbPatients, status, site, diagnosis, outcome, enrolled, finished, artstatus, cptstatus, daamin);

        return SimpleObject.fromCollection(wrapperList, ui, "wrapperRegisterDate", "wrapperTreatmentDate", "wrapperIdentifier", "wrapperNames", "wrapperStatus", "wrapperLocationId", "wrapperLocationName", "formartedVisitDate", "wrapperAddress", "patientProgram.patient.patientId", "patientProgram.patient.age", "patientProgram.patient.gender", "patientDetails.facility.name", "patientDetails.daamin", "patientDetails.diseaseSite.name", "patientDetails.patientCategory.concept.name", "patientDetails.patientType.concept.name", "wrapperCompletedDate", "wrapperOutcome", "wrapperArt", "wrapperCpt");
    }

    public List<SimpleObject> searchRegister(UiUtils ui,
                                             HttpServletRequest request) {
        Integer age = getInt(request.getParameter("age"));
        Integer ageRange = getInt(request.getParameter("ageRange"));
        Integer programId = getInt(request.getParameter("programId"));
        Integer locationId = getInt(request.getParameter("locations"));

        String gender = request.getParameter("gender");
        String daamin = request.getParameter("daamin");
        String enrolled = request.getParameter("enrolled");
        String finished = request.getParameter("finished");

        Integer status = getInt(request.getParameter("status"));
        Integer site = getInt(request.getParameter("site"));
        Integer outcome = getInt(request.getParameter("outcome"));
        Integer diagnosis = getInt(request.getParameter("diagnosis"));
        Integer artstatus = getInt(request.getParameter("artstatus"));
        Integer cptstatus = getInt(request.getParameter("cptstatus"));

        List<Location> locations = getLocations(locationId);

        List<MdrtbPatientProgram> mdrtbPatients = Context.getService(MdrtbDashboardService.class).getMdrtbPatients(gender, age, ageRange, programId, locations);
        List<MdrtbPatientWrapper> wrapperList = mdrtbPatientsWithDetails(mdrtbPatients, status, site, diagnosis, outcome, enrolled, finished, artstatus, cptstatus, daamin);

        return SimpleObject.fromCollection(wrapperList, ui, "wrapperRegisterDate", "wrapperTreatmentDate", "wrapperIdentifier", "wrapperNames", "wrapperStatus", "wrapperLocationId", "wrapperLocationName", "formartedVisitDate", "wrapperAddress", "patientProgram.patient.patientId", "patientProgram.patient.age", "patientProgram.patient.gender", "patientDetails.facility.name", "patientDetails.daamin", "patientDetails.diseaseSite.name", "patientDetails.patientCategory.concept.name", "patientDetails.patientType.concept.name", "wrapperCompletedDate", "wrapperOutcome", "wrapperArt", "wrapperCpt");
    }

    private List<Location> getLocations(Integer locationId) {
        List<Location> locations = new ArrayList<Location>();
        if (locationId == 0){
            locations = Context.getService(MdrtbService.class).getLocationsByUser();
        }
        else if (locationId == -1){
            //Do nothing, Returns all Patients (Even those you don't have access to
        }
        else if (locationId != null) {
            Location location = Context.getLocationService().getLocation(locationId);
            locations.add(location);
        }
        return locations;
    }

    private Integer getInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }

    private List<MdrtbPatientWrapper> mdrtbPatientsWithDetails(List<MdrtbPatientProgram> mdrtbPatients, Integer status, Integer site, Integer diagnosis, Integer outcome, String enrolled, String finished, Integer artstatus, Integer cptstatus, String daamin) {
        List<MdrtbPatientWrapper> wrappers = new ArrayList<MdrtbPatientWrapper>();
        for (MdrtbPatientProgram patientProgram : mdrtbPatients) {
            if ((status == 1 && patientProgram.getPatientProgram().getDateCompleted() != null) || (status == 2 && patientProgram.getPatientProgram().getDateCompleted() == null)){
                continue;
            }

            Integer year;
            Integer qntr;

            if (StringUtils.isNotBlank(enrolled)){
                year = Integer.parseInt(enrolled.substring(3));
                qntr = Integer.parseInt(enrolled.substring(0,2));
                DateRangeModel dates = new DateRangeModel(qntr , year);

                if (!(dates.getStartDate().compareTo(patientProgram.getDateEnrolled()) * patientProgram.getDateEnrolled().compareTo(dates.getEndDate()) >= 0)){
                    continue;
                }
            }

            if (StringUtils.isNotBlank(finished)){
                if (patientProgram.getDateCompleted() == null){
                    continue;
                }

                year = Integer.parseInt(finished.substring(3));
                qntr = Integer.parseInt(finished.substring(0,2));
                DateRangeModel dates = new DateRangeModel(qntr , year);

                if (!(dates.getStartDate().compareTo(patientProgram.getDateCompleted()) * patientProgram.getDateCompleted().compareTo(dates.getEndDate()) >= 0)){
                    continue;
                }
            }

            MdrtbPatientWrapper pw = new MdrtbPatientWrapper(patientProgram);
            if ((site==63 && pw.getPatientDetails().getDiseaseSite().getId()!=63) || (site==163 && pw.getPatientDetails().getDiseaseSite().getId()!=163)){
                continue;
            }
            if ((diagnosis==1160663 && pw.getPatientDetails().getConfirmationSite().getId()!=1160663) || (diagnosis==1160664 && pw.getPatientDetails().getConfirmationSite().getId()!=1160664)){
                continue;
            }
            if (outcome > 0 && pw.getPatientDetails().getOutcome() == null){
                continue;
            }
            if ((outcome==37 && pw.getPatientDetails().getOutcome().getId()!=37) || (outcome==57 && pw.getPatientDetails().getOutcome().getId()!=57) || (outcome==110 && pw.getPatientDetails().getOutcome().getId()!=110) || (outcome==147 && pw.getPatientDetails().getOutcome().getId()!=147) || (outcome==171 && pw.getPatientDetails().getOutcome().getId() != 171) || (outcome==181 && pw.getPatientDetails().getOutcome().getId()!=181)){
                continue;
            }
            if ((artstatus==126 && pw.getPatientDetails().getArtStarted().getId()!=126) || (artstatus==127 && pw.getPatientDetails().getArtStarted().getId()!=127)){
                continue;
            }
            if ((cptstatus==126 && pw.getPatientDetails().getCptStarted().getId()!=126) || (cptstatus==127 && pw.getPatientDetails().getCptStarted().getId()!=127)){
                continue;
            }

            if (StringUtils.isNotBlank(daamin)){
                if (!pw.getPatientDetails().getDaamin().toLowerCase().contains(daamin.toLowerCase())){
                    continue;
                }
            }

            wrappers.add(pw);
        }
        return wrappers;
    }
}
